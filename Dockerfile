FROM python:3.8.8-buster

LABEL name="Validate Colony Blueprints"
LABEL version="0.0.1"
LABEL repository="https://github.com/ddovbii/colony-demo-space"
LABEL homepage="https://github.com/ddovbii/colony-demo-space"

LABEL maintainer="Dmytro Docvii <dmytro.d@quali.com>"
LABEL com.github.actions.name="Validate Blueprints"
LABEL com.github.actions.description="Validates all blueprints in repo against desired space"
LABEL com.github.actions.icon="octagon"
LABEL com.github.actions.color="gray-dark"

#COPY entrypoint.sh cs18_client.py requirements.txt /
RUN pip install colony-cli
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

#RUN ["chmod", "+x", "/entrypoint.sh"]
#
#CMD ["help"]
