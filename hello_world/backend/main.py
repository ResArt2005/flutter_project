from fastapi import FastAPI, HTTPException, Depends, UploadFile, File, Form, Header
from sqlalchemy import create_engine, Column, Integer, String, Boolean, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.sql import func
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import os
import shutil
import uuid
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from passlib.context import CryptContext

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@postgres:5432/flutter_db")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Контекст для хеширования паролей
pwd_context = CryptContext(schemes=["sha256_crypt"], deprecated="auto")

# Модель базы данных
class UserDB(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=True)
    is_admin = Column(Boolean, default=False, nullable=False)

class PhotoDB(Base):
    __tablename__ = "photos"
    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String, nullable=False)
    filepath = Column(String, nullable=False)
    uploaded_at = Column(DateTime, server_default=func.now())
    size = Column(Integer, nullable=False)  # размер в байтах
    mime_type = Column(String, nullable=False)

# Создание таблиц
Base.metadata.create_all(bind=engine)

# Pydantic модели
class UserCreate(BaseModel):
    name: str
    email: str
    password: str = ""
    is_admin: bool = False

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    is_admin: bool

    class Config:
        from_attributes = True

class LoginRequest(BaseModel):
    username: str  # может быть email или имя
    password: str

class LoginResponse(BaseModel):
    success: bool
    user: Optional[UserResponse] = None
    message: str = ""

class PhotoCreate(BaseModel):
    filename: str
    filepath: str
    size: int
    mime_type: str

class PhotoResponse(BaseModel):
    id: int
    filename: str
    filepath: str
    uploaded_at: datetime
    size: int
    mime_type: str

    class Config:
        from_attributes = True

# FastAPI приложение
app = FastAPI(title="User Management API", version="1.0.0")

# Настройка CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # В продакшене заменить на конкретные домены
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Статическая раздача файлов из volume media
MEDIA_DIR = "/app/media"
os.makedirs(MEDIA_DIR, exist_ok=True)
app.mount("/media", StaticFiles(directory=MEDIA_DIR), name="media")

# Зависимость для сессии БД
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def read_root():
    return {"message": "User Management API is running"}

@app.get("/users", response_model=List[UserResponse])
def get_users(db: Session = Depends(get_db)):
    users = db.query(UserDB).all()
    return users

@app.post("/users", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    # Проверка на существующий email
    existing = db.query(UserDB).filter(UserDB.email == user.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    # Хеширование пароля
    password_hash = pwd_context.hash(user.password) if user.password else ""
    db_user = UserDB(name=user.name, email=user.email, password_hash=password_hash, is_admin=user.is_admin)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.delete("/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(UserDB).filter(UserDB.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(user)
    db.commit()
    return {"message": "User deleted successfully"}

@app.post("/auth/login", response_model=LoginResponse)
def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    # Ищем пользователя по email или name
    user = db.query(UserDB).filter(
        (UserDB.email == login_data.username) | (UserDB.name == login_data.username)
    ).first()
    if not user:
        return LoginResponse(success=False, message="User not found")
    # Проверяем пароль (сравниваем хеш)
    if not user.password_hash or not pwd_context.verify(login_data.password, user.password_hash):
        return LoginResponse(success=False, message="Invalid password")
    return LoginResponse(
        success=True,
        user=UserResponse(id=user.id, name=user.name, email=user.email, is_admin=user.is_admin),
        message="Login successful"
    )

# Зависимость для получения текущего пользователя по заголовку X-User-Id (упрощённо)
def get_current_admin(db: Session = Depends(get_db), user_id: Optional[int] = Header(None, alias="X-User-Id")):
    if user_id is None:
        raise HTTPException(status_code=401, detail="Authentication required")
    user = db.query(UserDB).filter(UserDB.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_admin:
        raise HTTPException(status_code=403, detail="Admin privileges required")
    return user

# Эндпоинты для работы с фото
@app.get("/photos", response_model=List[PhotoResponse])
def get_photos(db: Session = Depends(get_db)):
    photos = db.query(PhotoDB).all()
    return photos

@app.get("/photos/{photo_id}", response_model=PhotoResponse)
def get_photo(photo_id: int, db: Session = Depends(get_db)):
    photo = db.query(PhotoDB).filter(PhotoDB.id == photo_id).first()
    if not photo:
        raise HTTPException(status_code=404, detail="Photo not found")
    return photo

@app.post("/photos", response_model=PhotoResponse)
async def upload_photo(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_admin: UserDB = Depends(get_current_admin)
):
    # Проверка размера файла (максимум 5 МБ)
    MAX_SIZE = 5 * 1024 * 1024
    contents = await file.read()
    if len(contents) > MAX_SIZE:
        raise HTTPException(status_code=400, detail="File size exceeds 5 MB")
    # Проверка MIME-типа
    allowed_mime = {"image/jpeg", "image/png", "image/gif"}
    if file.content_type not in allowed_mime:
        raise HTTPException(status_code=400, detail="Unsupported file type. Only JPG, PNG, GIF allowed")
    # Генерация уникального имени файла
    import uuid
    ext = os.path.splitext(file.filename)[1] or ".jpg"
    filename = f"{uuid.uuid4().hex}{ext}"
    filepath = os.path.join(MEDIA_DIR, filename)
    # Сохранение файла
    with open(filepath, "wb") as f:
        f.write(contents)
    # Создание записи в БД
    db_photo = PhotoDB(
        filename=filename,
        filepath=filename,  # относительный путь внутри media
        size=len(contents),
        mime_type=file.content_type
    )
    db.add(db_photo)
    db.commit()
    db.refresh(db_photo)
    return db_photo

@app.delete("/photos/{photo_id}")
def delete_photo(
    photo_id: int,
    db: Session = Depends(get_db),
    current_admin: UserDB = Depends(get_current_admin)
):
    photo = db.query(PhotoDB).filter(PhotoDB.id == photo_id).first()
    if not photo:
        raise HTTPException(status_code=404, detail="Photo not found")
    # Удаление файла
    filepath = os.path.join(MEDIA_DIR, photo.filepath)
    if os.path.exists(filepath):
        os.remove(filepath)
    db.delete(photo)
    db.commit()
    return {"message": "Photo deleted successfully"}

# Эндпоинт для проверки здоровья
# Эндпоинт для изменения статуса администратора
@app.patch("/users/{target_user_id}/admin", response_model=UserResponse)
def set_admin_status(
    target_user_id: int,
    is_admin: bool = True,
    db: Session = Depends(get_db),
    current_admin: UserDB = Depends(get_current_admin)
):
    user = db.query(UserDB).filter(UserDB.id == target_user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_admin = is_admin
    db.commit()
    db.refresh(user)
    return user

@app.get("/health")
def health_check():
    return {"status": "healthy"}