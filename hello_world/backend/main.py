from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from pydantic import BaseModel
from typing import List, Optional
import os
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@postgres:5432/flutter_db")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Модель базы данных
class UserDB(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=True)

# Создание таблиц
Base.metadata.create_all(bind=engine)

# Pydantic модели
class UserCreate(BaseModel):
    name: str
    email: str
    password: str = ""

class UserResponse(BaseModel):
    id: int
    name: str
    email: str

    class Config:
        from_attributes = True

class LoginRequest(BaseModel):
    username: str  # может быть email или имя
    password: str

class LoginResponse(BaseModel):
    success: bool
    user: Optional[UserResponse] = None
    message: str = ""

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
    # Хеширование пароля (упрощённое)
    password_hash = user.password if user.password else ""
    db_user = UserDB(name=user.name, email=user.email, password_hash=password_hash)
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
    # Проверяем пароль (пока просто сравнение, так как пароль не хешируется)
    if user.password_hash != login_data.password:
        return LoginResponse(success=False, message="Invalid password")
    return LoginResponse(
        success=True,
        user=UserResponse(id=user.id, name=user.name, email=user.email),
        message="Login successful"
    )

# Эндпоинт для проверки здоровья
@app.get("/health")
def health_check():
    return {"status": "healthy"}