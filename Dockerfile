FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y wget less vim php python3 python3-pip
RUN pip3 install openai
RUN pip3 install openai[datalib]

ENV PYTHONUNBUFFERED=1 PYTHONIOENCODING=UTF-8

CMD ["/bin/bash"]
