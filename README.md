# riscVModified
XORI. Реализовать в АЛУ.

Вид получившейся команды:

|     31-20        |     19-15    |     f3     |     11-7    |     opcode     |
|------------------|--------------|------------|-------------|----------------|
|     imm[11:0]    |     rs1      |     100    |     rd      |     0010011    |

Для реализации XORI в тракте данных ничего добавлять не нужно. Добавляется только несколько элементов в управляющее устройство

    `define ALU_XOR      3'b101
    `define RVOP_XORI    7'b0010011
    `define RVF3_XORI   3'b100
    …
     { `RVF7_ANY,  `RVF3_XORI, `RVOP_XORI } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_XOR; end
 
Добавляем изменение в АЛУ

    `ALU_XOR : result = srcA ^ srcB;

Код тестовой программы

    .text
    start:      li t1, 184        #10111000   
                xori  a0, t1, 83  #01010011
    end:        beqz  zero, end   #a0 must be 11101011 - 235

Вывод симулятора

    3  pc = 00 instr = 0b800313   a0 = x   addi  $6, $0, 0x000000b8
    4  pc = 04 instr = 05334513   a0 = x   xori  $10, $6, 0x00000053
    5  pc = 08 instr = 00000063   a0 = 235   beq   $0, $0, 0x00000000 (0)

Видно, что 83 ^ 184 = 235, что программа нам и записала в регистр a0.


Для того, чтобы добавить инструкцию на основе функции, разработанной в 2 лабораторной необходимо добавить пару мультиплексоров в схему процессора
 ![image](https://github.com/Kurtlike/riscVModified/assets/43546532/59ee3f68-feb3-4eef-a2fe-fa9f4a9c1ec9)

Изменения коснулись, как и устройства управления, так и 2х мультиплексоров

    wire [31:0] wd3_1;
        assign wd3_1 = wdSrc ? immU : aluResult;
        assign wd3 = wdSrc[1]? myfunk_Result : wd3_1;
    …
    assign stop = myfunk_start | myfunk_busy;
    wire [31:0] pcBranch = stop? pc : pc + immB;
    wire [31:0] pcPlus4  = stop? pc : pc + 4;
    wire [31:0] pcNext   = pcSrc ? pcBranch : pcPlus4;
    sm_register r_pc(stop, clk ,rst_n, pcNext, pc);
    …
     always @ (posedge clk or negedge rst)
            if(!myfunk_busy) begin
                if(~rst)
                    q <= 32'b0;
                else
                    q <= d;
            end

Программа для тестирования 

    .text
    start:       li t1, 184
                   xori  a0, t1, 83
                   li a2, 8
                   li a1, 8
         myfunk  a0, a2, a1         
    end:        beqz    zero,  end


Вывод теста

        0  pc = xxxxxxxx instr = xxxxxxxx   a0 = x   new/unknown
        1  pc = 00 instr = 0b800313   a0 = x   addi  $6, $0, 0x000000b8
        2  pc = 00 instr = 0b800313   a0 = x   addi  $6, $0, 0x000000b8
        3  pc = 00 instr = 0b800313   a0 = x   addi  $6, $0, 0x000000b8
        4  pc = 04 instr = 05334513   a0 = x   xori  $10, $6, 0x00000053
        5  pc = 08 instr = 00800613   a0 = 235   addi  $12, $0, 0x00000008
        6  pc = 0c instr = 00800593   a0 = 235   addi  $11, $0, 0x00000008
        7  pc = 10 instr = 00b60517   a0 = 235   myfunk  $10, $12, 0x0000000b
        8  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
        9  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       10  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       11  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       12  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       13  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       14  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       15  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       16  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       17  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       18  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       19  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       20  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       21  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       22  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       23  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       24  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       25  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       26  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       27  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       28  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       29  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       30  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       31  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       32  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       33  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       34  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       35  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       36  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       37  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       38  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       39  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       40  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       41  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       42  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       43  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       44  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       45  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       46  pc = 10 instr = 00b60517   a0 = 0   myfunk  $10, $12, 0x0000000b
       47  pc = 14 instr = 00000063   a0 = 576   beq   $0, $0, 0x00000000 (0)

