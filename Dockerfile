FROM ubuntu:24.04

ARG USERNAME=hluser
ARG USER_UID=10000
ARG USER_GID=$USER_UID
ARG CHAIN=Testnet
ARG OVERRIDE_PEER_IPS=""
ARG OVERRIDE_TRY_NEW_PEERS=false

# create custom user, install dependencies, create data directory
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update -y && apt-get install curl -y \
    && mkdir -p /home/$USERNAME/hl/data && chown -R $USERNAME:$USERNAME /home/$USERNAME/hl

USER $USERNAME

WORKDIR /home/$USERNAME

# configure chain to testnet
RUN echo '{"chain": "'${CHAIN}'"}' > /home/$USERNAME/visor.json

# Configure gossip config
RUN echo '{ "root_node_ips": ['"$(echo $OVERRIDE_PEER_IPS | awk -F',' '{for(i=1;i<=NF;i++) printf "%s{\"Ip\": \"%s\"}", (i==1?"":","), $i}')"'], "try_new_peers": '${OVERRIDE_TRY_NEW_PEERS}', "chain": "'${CHAIN}'" }' > /home/$USERNAME/override_gossip_config.json

# save the public list of peers to connect to
ADD --chown=$USER_UID:$USER_GID https://binaries.hyperliquid.xyz/${CHAIN}/initial_peers.json /home/$USERNAME/initial_peers.json

# temporary configuration file (will not be required in future update)
ADD --chown=$USER_UID:$USER_GID https://binaries.hyperliquid.xyz/${CHAIN}/non_validator_config.json /home/$USERNAME/non_validator_config.json

# add the binary
ADD --chown=$USER_UID:$USER_GID --chmod=700 https://binaries.hyperliquid.xyz/${CHAIN}/hl-visor /home/$USERNAME/hl-visor

# gossip ports
EXPOSE 4000-4010

# run a non-validating node
ENTRYPOINT $HOME/hl-visor run-validator
