# CogniCraft Smart Contracts

## Environment variables

Copy `.env.example` to `.env` and fill in the variables.

## Setup

1. Install deps:

```shell
make
```

2. Run tests:

```shell
make test
```

3. Deploy:

Deploy to Sepolia:

```shell
make deploy-sepolia contract=<CONTRACT_NAME>
```

Or deploy to local network Anvil:

```shell
make deploy-anvil contract=<CONTRACT_NAME>
```

Remember that Anvil is a local network, so you need to run it first:

```shell
make anvil
```

## Other stuff

Format code:

```shell
make format
```

Add remappings:

```shell
forge remappings > remappings.txt
```
