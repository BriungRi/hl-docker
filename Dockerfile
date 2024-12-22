FROM ubuntu:24.04

ARG USERNAME=hluser
ARG USER_UID=10000
ARG USER_GID=$USER_UID
ARG CHAIN=
ARG OVERRIDE_PEER_IPS=unset
ARG OVERRIDE_TRY_NEW_PEERS=unset
ARG SIGNER_KEY=unset

# create custom user, install dependencies, create data directory
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update -y && apt-get install curl -y \
    && mkdir -p /home/$USERNAME/hl/data && chown -R $USERNAME:$USERNAME /home/$USERNAME/hl

USER $USERNAME

WORKDIR /home/$USERNAME

# configure chain to testnet
RUN echo '{"chain": "'${CHAIN}'"}' > /home/$USERNAME/visor.json

# Configure gossip config only if overrides are set
RUN if [ "$OVERRIDE_PEER_IPS" != "unset" ] && [ "$OVERRIDE_TRY_NEW_PEERS" != "unset" ]; then \
    echo '{ "root_node_ips": ['"$(echo $OVERRIDE_PEER_IPS | awk -F',' '{for(i=1;i<=NF;i++) printf "%s{\"Ip\": \"%s\"}", (i==1?"":","), $i}')"'], "try_new_peers": '${OVERRIDE_TRY_NEW_PEERS}', "chain": "'${CHAIN}'" }' > /home/$USERNAME/override_gossip_config.json; \
fi

# Configure signer key if provided
RUN if [ "$SIGNER_KEY" != "unset" ]; then \
    mkdir -p /home/$USERNAME/hl/hyperliquid_data && \
    echo '{"key": "'${SIGNER_KEY}'"}' > /home/$USERNAME/hl/hyperliquid_data/node_config.json; \
fi

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
