# Build the app on top of Python 3.x
FROM python:3.7

# Patch and Install Dependencies
RUN apt-get -y update && apt-get -y install git sqlite3 libsqlite3-dev && apt-get -y clean


# Add python requirements to the image
ADD requirements.txt /app/requirements.txt
ADD test-requirements.txt /app/test-requirements.txt

# Set a working directory
WORKDIR /app/

# Build the application
RUN pip install --no-cache-dir -r requirements.txt

# Add the application code to the image
ADD . /app/

RUN python manage.py migrate --settings=config.local

# Start postgres database and use it while it is running in the container
RUN python manage.py migrate --settings=config.local                         		&& \
    echo "from data.v2.build import build_all; build_all(); quit()" | python -u manage.py shell --settings=config.local

# Expose the app and serve the API.
EXPOSE 8000
ENTRYPOINT ["python", "manage.py runserver --settings=config.local 0.0.0.0:8000"]
