
# 📄 SimpleDEX - Descentralized Exchange (Ethereum Testnet)

SimpleDEX es un exchange descentralizado simple que permite agregar liquidez y realizar intercambios entre dos tokens ERC-20 (**TokenA** y **TokenB**).  
Este contrato fue creado como ejercicio académico en Solidity.

## ✅ Contratos desplegados y verificados

| Contrato         | Dirección                            |
|------------------|--------------------------------------|
| SimpleDEX        | `[0xc38b39ac4a6f0662f53ca84bad27f3d7d279bbfa](https://sepolia.etherscan.io/address/0xc38b39ac4a6f0662f53ca84bad27f3d7d279bbfa)`|
| TokenA (ERC-20)  | `[0x40afc073f0e299cadfb7cc3f01b151cd85404202](https://sepolia.etherscan.io/address/0x40afc073f0e299cadfb7cc3f01b151cd85404202)`|
| TokenB (ERC-20)  | `[0x71663164cb40f1278CdB81089DA5234d98b9d7C3](https://sepolia.etherscan.io/address/0x71663164cb40f1278CdB81089DA5234d98b9d7C3)`|

> ✅ Todos los contratos están **verificados en Etherscan**, por lo que puedes interactuar con ellos desde la interfaz web.

## 🔧 ¿Cómo interactuar desde Etherscan?

### 1. Aprobar tokens (`approve`)

Antes de que SimpleDEX pueda mover tus tokens, necesitas darle permiso mediante la función `approve`.

#### ➡️ TokenA y TokenB

1. Ve al contrato de **TokenA** o **TokenB** en Etherscan.
2. Haz clic en **Contract → Write Contract**.
3. Conecta tu wallet (botón "Connect to Web3").
4. Busca la función `approve` e ingresa:

```
spender: Dirección del contrato SimpleDEX (ej. 0xYourSimpleDexAddress)
amount:  Cantidad de tokens (en wei). Ej. 100000000000000000000 para aprobar 100 tokens con 18 decimales.
```

Repite el proceso para TokenB.

### 2. Agregar liquidez (solo owner)

1. Ve a **SimpleDEX → Write Contract**.
2. Conecta tu wallet.
3. Busca la función `addLiquidity` e ingresa:

```
amountOnTokenA: cantidad de TokenA a agregar (wei)
amountOnTokenB: cantidad de TokenB a agregar (wei)
```

### 3. Realizar intercambios

#### 🔁 TokenA → TokenB

1. Ve a **SimpleDEX → Write Contract**.
2. Ejecuta `swapAforB`.

```
amountOnTokenAIn: cantidad de TokenA a intercambiar (wei)
```

#### 🔁 TokenB → TokenA

1. Ve a **SimpleDEX → Write Contract**.
2. Ejecuta `swapBforA`.

```
amountOnTokenBIn: cantidad de TokenB a intercambiar (wei)
```

### 4. Consultar precios del pool

1. Ve a **SimpleDEX → Read Contract**.
2. Busca la función `getPrice`.
3. Ingresa la dirección del token del que quieres conocer el precio (`TokenA` o `TokenB`).

ℹ️ El precio es aproximado, calculado como la relación entre las reservas.

### 5. Retirar liquidez (solo owner)

1. Ve a **SimpleDEX → Write Contract**.
2. Ejecuta `removeLiquidity`.

```
amountOnTokenA: cantidad de TokenA a retirar (wei)
amountOnTokenB: cantidad de TokenB a retirar (wei)
```

## ⚠️ Consideraciones importantes

- Todas las cantidades deben expresarse en **wei**, no en tokens enteros.  
  Ejemplo: `1 ether = 1000000000000000000`.
- Debes realizar `approve()` cada vez que quieras permitir al contrato transferir tus tokens.
- No puedes realizar intercambios si no hay liquidez suficiente.
- La fórmula de intercambios usa el modelo de producto constante (`xy = k`) y **no aplica comisiones**.
