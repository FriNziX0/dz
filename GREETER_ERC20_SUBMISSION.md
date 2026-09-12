# Домашнє завдання: ERC-20 для `Greeter`

**Дисципліна:** Розробка Fintech-додатків: Blockchain, криптовалюти, смарт-контракти, Solidity  
**Тема:** Смарт-контракти  
**Викладач:** Самойленко Денис Миколайович

## Виконання

Контракт [contracts/Greeter.sol](contracts/Greeter.sol) доповнено базовою імплементацією стандарту ERC-20 без зовнішніх бібліотек.

Реалізовані методи стандарту:

- `name`, `symbol`, `decimals`;
- `totalSupply`, `balanceOf`;
- `transfer`;
- `allowance`, `approve`, `transferFrom`.

Під час розгортання власник контракту (`msg.sender`) отримує `initialSupply` токенів. Параметр `initialSupply` задається у цілих токенах; контракт додає 18 десяткових розрядів, тому `1000` перетворюється у `1000 * 10^18` найменших одиниць.

Методи `transfer` і `transferFrom` генерують подію `Transfer`, а `approve` — подію `Approval`. Передбачені перевірки нульових адрес, балансу й allowance. Нескінченний allowance (`type(uint256).max`) не зменшується після `transferFrom`, як у OpenZeppelin ERC-20.

Попередня логіка `Greeter` не видалена: власник керує переліком дозволених вузлів, а лише власник або дозволений вузол можуть викликати `setGreeting`.

## Конструктор

```solidity
new Greeter("Hello", "Greeter Token", "GRT", 1000)
```

## Перевірка

Тести: [test/Greeter.ts](test/Greeter.ts).

```powershell
npx hardhat build
npx tsc --noEmit
npx hardhat test mocha test/Greeter.ts
```
