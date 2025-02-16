FROM python:3.9
WORKDIR /app

# Copy dependencies first
COPY requirements.txt .
RUN pip install -r requirements.txt

# Now copy the entire app source code
COPY ./src /app/src

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "src.backend.app:app"]

