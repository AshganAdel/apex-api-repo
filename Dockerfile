FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

RUN useradd appuser

USER appuser

CMD [ "python3" , "main.py" ]