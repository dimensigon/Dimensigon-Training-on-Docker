FROM python:3.6

# Expose port 5000 (adjust as needed)
EXPOSE 5000

# Install sudo and add dimensigon user
RUN apt-get update && apt-get install -y sudo && \
    useradd -m dimensigon && \
    echo "dimensigon ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy the tar.gz file to HOME dir.
ADD --chown=dimensigon:dimensigon https://www.dimensigon.com/wp-content/dm-download/dimensigon-py36.tar.gz /home/dimensigon/

# Set up Python Virtual Environment
RUN su - dimensigon -c "python3 -m venv --prompt dimensigon ~/venv"
RUN su - dimensigon -c "echo 'source ~/venv/bin/activate' >> ~/.bash_profile"

# Install prerequisites using the virtual environment's pip
RUN su - dimensigon -c "~/venv/bin/pip install wheel"
RUN su - dimensigon -c "~/venv/bin/pip install setuptools_rust"
RUN su - dimensigon -c "~/venv/bin/pip install --upgrade pip"
RUN su - dimensigon -c "~/venv/bin/pip install pyperclip"

# Install dimensigon package from the tar.gz file
RUN su - dimensigon -c "~/venv/bin/pip install /home/dimensigon/dimensigon-py36.tar.gz"

# Create .dshell configuration file
RUN echo "\
[AUTH]\n\
username = dm\n\
[REMOTE]\n\
server = 127.0.0.1\n\
port = 5000\n\
" > /home/dimensigon/.dshell && \
    chown dimensigon:dimensigon /home/dimensigon/.dshell

# Switch to the dimensigon user
USER dimensigon

# Set the working directory to the dimensigon user's home directory
WORKDIR /home/dimensigon

# Set ENTRYPOINT to start a bash shell
ENTRYPOINT ["/bin/bash", "-l"]
