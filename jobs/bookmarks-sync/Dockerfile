FROM python:3.12-alpine
RUN pip install --no-cache-dir PyYAML
COPY sync_bookmarks.py /app/sync_bookmarks.py
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
ENTRYPOINT ["python", "/app/sync_bookmarks.py"]
