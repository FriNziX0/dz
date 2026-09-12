# Домашнє завдання: число у двійковий рядок

**Дисципліна:** Розробка Fintech-додатків: Blockchain, криптовалюти, смарт-контракти, Solidity  
**Тема:** Solidity  
**Викладач:** Самойленко Денис Миколайович

## Завдання

Скласти метод мовою Solidity, який перетворює число у його двійкове представлення у вигляді рядка та ділить його на групи по 8 біт.

## Реалізація

Контракт: [contracts/BinaryConverter.sol](contracts/BinaryConverter.sol).

```solidity
function numberToBinary(uint256 value) public pure returns (string memory)
```

Метод визначає мінімальну кількість байтів для числа, послідовно перевіряє кожен біт операцією `&` (побітове «І») і додає пробіл після кожних 8 біт.

Приклад:

```text
25901 -> 01100101 00101101
```

Також:

```text
5   -> 00000101
256 -> 00000001 00000000
0   -> 00000000
```

## Перевірка

Тести: [test/BinaryConverter.ts](test/BinaryConverter.ts).

```powershell
npx hardhat build
npx tsc --noEmit
npx hardhat test mocha test/BinaryConverter.ts
```
