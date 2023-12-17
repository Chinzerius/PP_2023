/* БВТ2204 для МТУСИ
Здравствуйте, в коде часто будете видеть emit, так вот События в Solidity позволяют контракту 
уведомлять внешние приложения о возникновении определенных событий в контракте. Когда событие генерируется 
с помощью emit, внешние приложения (например, веб-интерфейсы или другие контракты) могут подписываться на это 
событие и реагировать на него. Это способ обеспечения взаимодействия контракта с внешним миром.
 */



pragma solidity 0.8.20;
/* Абстрактный контракт и интерфейс:
   - abstract contract Context - Абстрактный контракт Context, содержащий виртуальную функцию _msgSender.
   - interface IERC20 - Интерфейс для стандартного функционала ERC20-токена, включая методы для получения 
   общего количества токенов, баланса аккаунта, передачи токенов и разрешения на их передачу. */
abstract contract Context { 
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
 /* Код представляет собой интерфейс для работы с токеном. Он содержит методы для получения общего количества токенов 
 (totalSupply), для проверки баланса аккаунта (balanceOf), для передачи токенов другому аккаунту (transfer), для
проверки доступного количества токенов для передачи (allowance), для установки разрешения на передачу токенов от 
имени владельца (approve) и для фактической передачи токенов от имени владельца (transferFrom).
Также интерфейс содержит события Transfer и Approval, которые вызываются при соответствующих операциях с токенами. */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval (address indexed owner, address indexed spender, uint256 value);
}
/* - library SafeMath - Библиотека, содержащая безопасные математические операции для избежания переполнения 
или деления на ноль. */
// внизу как раз умножение, деление, сложение и вычитание
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
 /* Это функция умножения двух чисел типа uint256. Она используется для безопасного умножения чисел типа uint256, 
 чтобы избежать переполнения (overflow) при умножении. Функция проверяет, что результат умножения (c) равен a * b и 
 если это условие выполняется, то возвращает результат умножения. Если же результат умножения не соответствует этому
  условию, то выбрасывается исключение с сообщением "SafeMath: multiplication overflow". Важно использовать безопасные 
  операции при работе с числами в Solidity, чтобы избежать уязвимостей и ошибок в программном обеспечени */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
 /* Этот код представляет собой безопасную функцию деления для типа uint256 в Solidity. Первая функция просто 
 вызывает вторую функцию div и передает ей сообщение об ошибке "SafeMath: division by zero". Вторая функция выполняет
  само деление, однако перед этим проверяет делитель на то, что он не равен 0, и если это условие не выполняется, то
   выбрасывается исключение с переданным сообщением об ошибке. Если делитель не равен 0, то выполняется обычное 
   деление и результат возвращается. Это помогает избежать деления на ноль, что может привести к непредвиденным 
   последствиям в программе. */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}
/*  - contract Ownable - Контракт, содержащий механизмы для управления владельцем контракта, включая проверки на 
собственность и утрату собственности. Также он определяет событие OwnershipTransferred. */
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
/* `address msgSender = _msgSender();` - получаем адрес отправителя транзакции с использованием вспомогательной 
функции _msgSender(), которая возвращает адрес отправителя. `_owner = msgSender;` - устанавливаем значение переменной 
_owner равным адресу отправителя транзакции, тем самым устанавливая отправителя в качестве владельца контракта.
 `emit OwnershipTransferred(address(0), msgSender);` - создаем событие OwnershipTransferred, указывая, что владелец 
 был перенесен с адреса 0 на адрес msgSender. */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
// это функция для получения адреса текущего владельца контракта.
    function owner() public view returns (address) {
        return _owner;
    }
/* это модификатор, который требует, чтобы функция, к которой он применяется, была вызвана только текущим владельцем
 контракта. */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _; /* проверяем, что адрес вызывающего функцию (_msgSender) совпадает с адресом владельца (_owner). 
        Если это не так, то выбрасываем исключение с сообщением "Ownable: caller is not the owner". */
    }
/* - это функция, которая позволяет владельцу отказаться от владения контрактом. Она также имеет модификатор 
onlyOwner, что требует, чтобы только владелец мог вызвать эту функцию.
*/
    function renounceOwnership() public virtual onlyOwner {
      //создаем событие OwnershipTransferred, указывая, что владелец был перенесен с адреса _owner на адрес 0.  
        emit OwnershipTransferred(_owner, address(0)); 
      //   устанавливаем значение переменной _owner в 0, тем самым отказываясь от владения контрактом.     
        _owner = address(0);

    }
    /* Будующему себе, я устал комментировать код, надеюсь не зря */

}
/* - interface IUniswapV2Factory, interface IUniswapV2Router02 - Интерфейсы для взаимодействия с протоколом Uniswap, 
включая создания пары токенов, а также функции для обмена токенов с Ethereum и добавления ликвидности. */
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
  /* которая позволяет обменять определенное количество токенов на ETH и поддерживает возможность взимания 
  комиссии при переводе токенов. */
    function swapExactTokensForETHSupportingFeeOnTransferTokens( 
        uint amountIn, //объявление входного параметра amountIn, который представляет собой количество входных токенов для обмена.
        uint amountOutMin,/*  объявление входного параметра amountOutMin, который представляет минимальное количество ETH,
         которое пользователь готов получить в результате обмена. */
        address[] calldata path,
        /* объявление входного параметра path, представляющего собой массив адресов токенов, которые будут
         использованы для обмена.  */
        address to, // address to, - объявление входного параметра to, который представляет собой адрес, на который будут отправлены обмененные ETH.
        uint deadline /*uint deadline - объявление входного параметра deadline, который представляет собой время 
        в формате Unix timestamp, до которого операция должна быть завершена */
         
    ) external; //  указывает на то, что функция доступна для вызова извне контракта.
    function factory() external pure returns (address); /* - объявление функции factory, которая возвращает адрес
     фабрики (factory) для создания пар токенов. */
    function WETH() external pure returns (address); //объявление функции WETH, которая возвращает адрес Wrapped Ether (WETH) - токена, представляющего 1:1 связь с Ether (ETH).
    function addLiquidityETH( //объявление функции addLiquidityETH, которая позволяет добавить ликвидность к паре токенов с использованием ETH.
        address token, // объявление входного параметра token, представляющего собой адрес токена, к которому будет добавлена ликвидность.
        uint amountTokenDesired, //  объявление входного параметра amountTokenDesired, представляющего желаемое количество токенов для добавления ликвидности.
        uint amountTokenMin, // бъявление входного параметра amountTokenMin, который представляет минимальное количество токенов, которое будет добавлено в результате операции.
        uint amountETHMin,// объявление входного параметра amountETHMin, который представляет минимальное количество ETH, которое будет добавлено в результате операции.
        address to, // - указание входного параметра to, представляющего собой адрес получателя ликвидности.
        uint deadline // объявление входного параметра deadline, который представляет собой время в формате Unix timestamp, до которого операция должна быть завершена.
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    /* указание на то, что функция доступна для вызова извне контракта и возвращает количество токенов, 
    количество ETH и количество ликвидности, добавленной к паре токенов. */
}
/*    - contract МТУСИ - Основной контракт, который реализует стандартный функционал ERC20-токена. Он также содержит
логику налогообложения для покупки и продажи токенов, механизмы исключения адресов от комиссий, а также 
взаимодействие с протоколом Uniswap. Данный код реализует возможность создания и управления токеном на блокчейне 
Ethereum, в том числе настройку налогов, механизмы управления владельцем контракта, а также взаимодействие с
 протоколом Uniswap для обмена и предоставления ликвидности. */
contract MTUCI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    /* объявление приватного отображения (mapping) _balances, которое отображает адрес кошелька на количество
     токенов этого адреса. */
    mapping (address => uint256) private _balances;
    /*  объявление приватного отображения _allowances, которое отображает адрес владельца на отображение адреса, 
    разрешенного к снятию средств, и количество разрешенных токенов */
    mapping (address => mapping (address => uint256)) private _allowances;
    /* объявление приватного отображения _isExcludedFromFee, которое отображает адрес на значение типа bool, 
    указывающее, исключен ли этот адрес из уплаты комиссии. */
    mapping (address => bool) private _isExcludedFromFee;
    /* объявление приватного отображения bots, которое отображает адреса на значения типа bool, 
    используемые для отслеживания того, является ли адрес ботом. */
    mapping (address => bool) private bots;
    /* объявление приватной переменной _taxWallet, представляющей собой адрес кошелька, куда будут поступать 
    комиссионные сборы. */
    address payable private _taxWallet;
    uint256 firstBlock; // объявление переменной firstBlock типа uint256 для хранения номера первого блока.

    uint256 private _initialBuyTax=24; //бъявление приватной переменной _initialBuyTax типа uint256 и присваивание ей значения 24.
    uint256 private _initialSellTax=24; // дальше прринципе тоже самое
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=19;
    uint256 private _reduceSellTaxAt=29;
    uint256 private _preventSwapBefore=20;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 6900000000 * 10**_decimals;
    string private constant _name = unicode"MTUCI";
    string private constant _symbol = unicode"MTUCI";
    uint256 public _maxTxAmount = 138000000 * 10**_decimals;
    uint256 public _maxWalletSize = 138000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 69000000 * 10**_decimals;
    uint256 public _maxTaxSwap= 69000000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
/* Событие MaxTxAmountUpdated объявляет событие, которое будет вызываться при обновлении максимальной суммы транзакции.
Модификатор lockTheSwap используется для блокировки обмена. При вызове функции с этим модификатором переменная inSwap 
устанавливается в значение true (блокировка), затем выполняется код функции, после чего переменная inSwap
 устанавливается обратно в значение false (снятие блокировки). Это позволяет предотвратить одновременное выполнение 
 обмена на свопе. */
    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    /* Фрагмент кода описывает логику обработки транзакций. Здесь проверяется ряд условий для различных видов 
транзакций и применяются соответствующие налоговые ставки. Первый блок условий относится к сделкам с парами Uniswap.
 Если транзакция выполняется между парами Uniswap и не относится к операциям с обменником Uniswap, то выполняются 
определенные проверки для лимитов максимальной суммы транзакции и максимального размера кошелька. Также проверяется, 
не является ли адрес контрактом, и увеличивается счетчик количества сделок для налогообложения покупок.
Далее проверяется сумма налоговых сборов на основе типа транзакции и производится обработка налоговых сборов 
в зависимости от типа транзакции. В конце проверяется, не превышает ли баланс контракта пороговое значение и, если это
так, производится обмен токенов на ETH и пересылка ETH на адреса для оплаты налоговых сборов. Также применяется и 
инкрементируется счетчик совершенных транзакций и учета налогов при покупке. По окончанию логики происходит обновление
 балансов адресов и регистрация событий трансфера токенов. */
/* Этот код инициализирует конструктор контракта с определенными значениями. Он делает адрес, вызвавший функцию, 
адресом, куда будут отправляться платежи. Также устанавливает баланс вызвавшего адреса как общее количество токенов.
 Он также исключает владельца контракта, сам контракт и адрес _taxWallet от комиссии. Наконец, код создает событие 
 Transfer для эмитации транзакции создания токенов от адреса 0 к вызвавшему адресу. */
    constructor () {

        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {
        return _name; //возвращает название токена
    }

    function symbol() public pure returns (string memory) {
        return _symbol; // возвращает символ токена 
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    } /* Объявление функции totalSupply(), которая переопределяет функцию из базового контракта и возвращает 
    целое число без знака размером 256 бит и объявлена как чистая (pure).
 */

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account]; //Возвращает баланс токенов на указанном адресе.
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true; // Передает определенное количество токенов на адрес получателя.
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender]; /* Возвращает количество токенов, которые владелец разрешил передавать 
        определенному адресу. */
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    } // Разрешает определенному адресу передавать определенное количество токенов от вашего адреса..

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;  /* Передает определенное количество токенов от одного адреса к другому, если отправитель получил 
        разрешение от владельца токенов на это действие. */
    }
/* Этот код представляет собой приватную функцию _approve, которая используется для установки разрешений на
 передачу средств между адресами в контракте ERC20 (стандарт для токенов на блокчейне Ethereum).  */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
/* Сначала функция проверяет, что owner и spender не равны адресу нулевого счета, используя require, чтобы избежать 
передачи разрешений от или к нулевому адресу. Затем функция устанавливает разрешение в переменной _allowances 
(маппинг из owner и spender в количество токенов, на которые разрешена передача) на указанное amount. В конце функция
 вызывает событие Approval, чтобы уведомить об установке разрешения на передачу токенов между owner и spender.
Этот код позволяет управлять разрешениями на передачу токенов в контракте ERC20. */
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 /* Функция _transfer проводит транзакции между адресами. В начале функция проверяет, что адрес отправителя и 
 получателя не являются нулевыми адресами, а также проверяет, что сумма перевода больше нуля. Затем происходит 
 проверка, являются ли адреса отправителя и получателя ботами. 
 */
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
/* Данный код представляет собой часть функции или фрагмент кода контракта, контракта ERC20
Основные действия этого фрагмента кода включают проверку различных условий и выполнение различных действий перед и 
после передачи токенов между адресами.

Здесь выполняются следующие действия:
- Проверяется условие, что отправитель и получатель не являются владельцем контракта.
- Проверяется, что это не транзакция от ботов (автоматизированных программ) и не к ботам.
- Вычисляется сумма налога.
- Проверяется различные условия для различных типов транзакций (например, для транзакций покупки или продажи токенов).
- Если выполнены условия, то происходит обмен токенов на Ethereum и отправка части средств на комиссии и др.

Затем происходит изменение балансов токенов у соответствующих адресов.

Этот фрагмент кода включает много сложных операций, таких как проверки балансов, выполнение различных действий в
 зависимости от типа транзакции и проведение операций свопа токенов.
 */
        if (from != owner() && to != owner()) {
            require(!bots[from] && !bots[to]);
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");

                if (firstBlock + 3  > block.number) {
                    require(!isContract(to));
                }
                _buyCount++;
            }
/*  Если кратко вот что значат эти if
1. Проверяем, что отправитель не является владельцем контракта и получатель не является владельцем контракта.
2. Требуется, чтобы отправитель и получатель не были ботами.
3. Вычисляем размер налога на основе суммы и текущего процента налога на покупку, учитывая условие снижения налога
 после определенного количества покупок.
4. Проверяем, что отправитель - это пара uniswapV2Pair, получатель не является адресом uniswapV2Router и не исключен
из комиссии.
5. Требуется, чтобы сумма была не больше чем _maxTxAmount (максимальная сумма транзакции).
6. Требуется, чтобы баланс получателя плюс сумма не превысили _maxWalletSize (максимальный размер кошелька).
7. Если это первые 3 блока после развертывания контракта, требуется, чтобы получатель не был контрактом.
8. Увеличиваем счетчик покупок (_buyCount). */
            if (to != uniswapV2Pair && ! _isExcludedFromFee[to]) {
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap { 
/* Объявление функции swapTokensForEth с параметром tokenAmount типа uint256. Он также помечен 
как приватный и имеет модификатор lockTheSwap. */
        address[] memory path = new address[](2); // Объявление временного массива адресов path длиной 2.
        path[0] = address(this); //Установка адреса текущего контракта в качестве первого элемента массива path.
        path[1] = uniswapV2Router.WETH(); //  Установка адреса WETH (Wrapped Ether) из UniswapV2 в качестве второго элемента массива path.
        _approve(address(this), address(uniswapV2Router), tokenAmount); 
//Вызов функции _approve для данного контракта, разрешая UniswapV2Router распоряжаться определенным количеством токенов.
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
/* ызов функции swapExactTokensForETHSupportingFeeOnTransferTokens у объекта uniswapV2Router, принимающей следующие параметры:
    - `tokenAmount`: Количество токенов для обмена на ETH.
    - `0`: Минимальное количество ETH, которое должно быть получено в результате обмена.
    - `path`: Массив, определяющий путь обмена (токен -> WETH).
    - `address(this)`: Адрес, на который будут отправлены полученные ETH.
    - `block.timestamp`: Временная метка блока на момент вызова функции. */
    }

    function removeLimits() external onlyOwner{  //это что бы лимиты убирать
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private { // это что бы за газ платить
        _taxWallet.transfer(amount);
    }
// Функция addBots добавляет адреса ботов в массив bots, присваивая каждому адресу значение true.
    function addBots(address[] memory bots_) public onlyOwner { 
        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
    }
// Функция delBots удаляет адреса из массива bots, устанавливая для каждого адреса значение false.
    function delBots(address[] memory notbot) public onlyOwner {
      for (uint i = 0; i < notbot.length; i++) {
          bots[notbot[i]] = false;
      }
    }
/* Функция isBot позволяет проверить, является ли указанный адрес ботом, возвращая значение true или false
 в зависимости от того, есть ли он в массиве bots. */
    function isBot(address a) public view returns (bool){
      return bots[a];
    }
/* Эта функция "openTrading" выполняет несколько действий при открытии торгов. Сначала она проверяет, что торговля еще 
не открыта, затем устанавливает адрес для доступа к Uniswap V2 Router, создает пару на Uniswap для токена, добавляет 
ликвидность на Uniswap, устанавливает разрешения для обмена токена на паре Uniswap, включает функцию обмена и 
устанавливает флаг открытия торгов. Также она принимает эфир через функцию "receive". В конце функция сохраняет номер
текущего блока. */
    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
        firstBlock = block.number;
    }

    receive() external payable {}

}
