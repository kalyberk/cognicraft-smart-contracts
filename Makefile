-include .env

.PHONY	: all clean remove install update build test snapshot slither format lint anvil deploy-sepolia deploy-anvil deploy-all

all		: clean remove install build

clean	:; forge clean

remove	:; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules

install	:; forge install foundry-rs/forge-std --no-commit && forge install openZeppelin/openzeppelin-contracts-upgradeable@v4.9.3 --no-commit && forge install openZeppelin/openzeppelin-contracts@v4.9.3 --no-commit

# update	:; forge update

build	:; forge build

test	:; forge test

# snapshot	:; forge snapshot

# slither	:; slither ./src

format	:; prettier --write src/**/*.sol && prettier --write src/*.sol

# solhint should be installed globally
# lint	:; solhint src/**/*.sol && solhint src/*.sol

anvil	:; anvil -m 'test test test test test test test test test test test junk'

# Below contains a random private key from anvil
deploy-anvil 	:; @forge script script/Deploy${contract}.s.sol:Deploy${contract} --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

deploy-sepolia  :; @forge script script/Deploy${contract}.s.sol:Deploy${contract} --rpc-url ${SEPOLIA_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv
