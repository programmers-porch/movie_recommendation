from werkzeug.security import generate_password_hash, check_password_hash

def hash_password(password: str) -> str:
    return generate_password_hash(password)

def check_password(hash_str: str, password: str) -> bool:
    return check_password_hash(hash_str, password)
