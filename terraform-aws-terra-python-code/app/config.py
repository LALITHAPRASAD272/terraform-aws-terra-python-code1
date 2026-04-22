import os

class Config:
    # Read each value from environment variable
    DB_HOST     = os.environ.get('DB_HOST')        # Your RDS endpoint URL
    DB_USER     = os.environ.get('DB_USER')        # Database username
    DB_PASSWORD = os.environ.get('DB_PASSWORD')    # Database password
    DB_NAME     = os.environ.get('DB_NAME', 'studentdb')  # Database name

    # Build the SQLAlchemy connection URL
    SQLALCHEMY_DATABASE_URI = (
        f'mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}'
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
