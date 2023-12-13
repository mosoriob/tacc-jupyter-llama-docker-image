FROM jupyter/datascience-notebook:ubuntu-22.04

# The user must be swtiched to root in order to install and update packages with apt-get.
# See https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile for info.
USER root

RUN apt-get update && apt-get install -y \
    ssh \
    vim \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda
ENV PATH=$PATH:/miniconda/condabin:/miniconda/bin

RUN mkdir -p /home
RUN chmod a+rwx /home

COPY run.sh /tapis/run.sh
## copy files

RUN chmod +x /tapis/run.sh

# The user is switched back to the one from set in the base image.
USER 1000
arg GH_USER=In-For-Disaster-Analytics 
arg GH_REPO=sites-and-stories-nlp 
arg GH_BRANCH=jupyterenv 

RUN wget https://github.com/$GH_USER/$GH_REPO/archive/refs/heads/$GH_BRANCH.zip -O /home/$GH_REPO-$GH_BRANCH.zip
RUN unzip /home/$GH_REPO-$GH_BRANCH.zip
RUN rm /home/$GH_REPO-$GH_BRANCH.zip

RUN conda env create -n myenv -f /home/jovyan/sites-and-stories-nlp-jupyterenv/environment.yml
SHELL ["conda","run","-n","myenv","/bin/bash","-c"]
RUN python -m ipykernel install --user --name myenv --display-name "Python (myenv)"


ENTRYPOINT [ "/tapis/run.sh" ]
