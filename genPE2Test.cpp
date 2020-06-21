#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include <map>


enum OP
{
    OP_NOP,
    OP_MOV1_2,
    OP_MOV2_1,
    OP_ADD,
    OP_MUL,
    OP_AND,
    OP_SWITCH_PRED,
    OP_SWITCH_TAG,
    OP_SYNC,
    OP_COMBINE_TAG,
    OP_NEW_TAG,
    OP_STORE_TAG,
    OP_RESTORE_TAG,
    OP_LOOP_HEAD,
    OP_INV_DATA,
    OP_ADD_DATA,
    OP_LT_DATA,
    OP_EQ_DATA,
    OP_NE_DATA,
    OP_ST,
    OP_DISCARD
};

enum DIR { U0=0, U1=1, D0=2, D1=3, L0=4, L1=5, R0=6, R1=7 };

std::pair<DIR, const char*> DirNames[] =
{
    std::pair<DIR, const char*>(U0, "U0"), std::pair<DIR, const char*>(U1, "U1"),
    std::pair<DIR, const char*>(D0, "D0"), std::pair<DIR, const char*>(D1, "D1"),
    std::pair<DIR, const char*>(L0, "L0"), std::pair<DIR, const char*>(L1, "L1"),
    std::pair<DIR, const char*>(R0, "R0"), std::pair<DIR, const char*>(R1, "R1")
};

std::pair<OP, const char*> OpNames[] =
{
    std::pair<OP, const char*>(OP_NOP,          "NOP"),
    std::pair<OP, const char*>(OP_MOV1_2,       "MOV1_2"),
    std::pair<OP, const char*>(OP_MOV2_1,       "MOV2_1"),
    std::pair<OP, const char*>(OP_INV_DATA,     "INV_DATA"),
    /* ADD_DATA should be put before ADD since ADD is a sub-string of ADD_DATA
       and we should compare longer string first */
    std::pair<OP, const char*>(OP_ADD_DATA,     "ADD_DATA"),
    std::pair<OP, const char*>(OP_ADD,          "ADD"),
    std::pair<OP, const char*>(OP_MUL,          "MUL"),
    std::pair<OP, const char*>(OP_AND,          "AND"),
    std::pair<OP, const char*>(OP_SWITCH_PRED,  "SWITCH_PRED"),
    std::pair<OP, const char*>(OP_SWITCH_TAG,   "SWITCH_TAG"),
    std::pair<OP, const char*>(OP_SYNC,         "SYNC"),
    std::pair<OP, const char*>(OP_COMBINE_TAG,  "COMBINE_TAG"),
    std::pair<OP, const char*>(OP_NEW_TAG,      "NEW_TAG"),
    std::pair<OP, const char*>(OP_STORE_TAG,    "STORE_TAG"),
    std::pair<OP, const char*>(OP_RESTORE_TAG,  "RESTORE_TAG"),
    std::pair<OP, const char*>(OP_LOOP_HEAD,    "LOOP_HEAD"),
    std::pair<OP, const char*>(OP_LT_DATA,      "LT_DATA"),
    std::pair<OP, const char*>(OP_EQ_DATA,      "EQ_DATA"),
    std::pair<OP, const char*>(OP_NE_DATA,      "NE_DATA"),
    std::pair<OP, const char*>(OP_ST,           "ST"),
    std::pair<OP, const char*>(OP_DISCARD,      "DISCARD") 
};

const char *TokData = "DATA";

bool IsInString = false;
int X, Y;

void chk_error(bool cond, int line)
{
    if (!(cond)) {
        fprintf(stderr, "Error at line %d, (%d, %c)\n", line, Y+1, X+'A');
        exit(1);
    }
}
    
#define CHK_ERROR(COND) chk_error(COND, __LINE__)

void filterSpace(char *&ptr)
{
    if (IsInString)
    {
        while (*ptr == ' ' || *ptr == '\n' || *ptr == '\r')
            ptr++;
    }
    else
    {
        while (*ptr == ' ')
            ptr++;
    }
}

bool hasNextDesc(char *&ptr)
{
    filterSpace(ptr);
    if (*ptr == '\n' || *ptr == 0)
        return false;
    return true;
}

bool hasNextLine(char *&ptr)
{
    CHK_ERROR(!IsInString);
    filterSpace(ptr);
    if (*ptr == '\n' || *ptr == '\r')
        return true;
    return false;
}

void matchNextLine(char *&ptr)
{
    CHK_ERROR(!IsInString);
    filterSpace(ptr);
    bool hasMatch = false;
    while (*ptr == '\n' || *ptr == '\r')
    {
        hasMatch = true;
        ptr++;
    }
    CHK_ERROR(hasMatch);
    filterSpace(ptr);
}

void matchNextDelim(char *&ptr, char delim)
{
    filterSpace(ptr);
    CHK_ERROR(*ptr == delim);
    ptr++;
    filterSpace(ptr);
}

bool hasNextOp(char *&ptr)
{
    filterSpace(ptr);
    for (int i = 0; i < sizeof(OpNames)/sizeof(OpNames[0]); i++)
    {
        if (strstr(ptr, OpNames[i].second) == ptr)
            return true;
    }
    return false;
}

bool hasNextDir(char *&ptr)
{
    filterSpace(ptr);
    for (int i = 0; i < sizeof(DirNames)/sizeof(DirNames[0]); i++)
    {
        if (strstr(ptr, DirNames[i].second) == ptr)
            return true;
    }
    return false;
}

bool hasNextData(char *&ptr)
{
    filterSpace(ptr);
    if (strstr(ptr, TokData) == ptr)
        return true;
    return false;
}

bool hasNextInt(char *&ptr)
{
    filterSpace(ptr);
    if (ptr[0] == '0' && ptr[1] == 'x')
        return true;
    return false;
}

OP getNextOp(char *&ptr)
{
    filterSpace(ptr);
    for (int i = 0; i < sizeof(OpNames)/sizeof(OpNames[0]); i++)
    {
        if (strstr(ptr, OpNames[i].second) == ptr)
        {
            ptr += strlen(OpNames[i].second);
            return OpNames[i].first;
        }
    }
    CHK_ERROR(false);
}

DIR getNextDir(char *&ptr)
{
    filterSpace(ptr);
    for (int i = 0; i < sizeof(DirNames)/sizeof(DirNames[0]); i++)
    {
        if (strstr(ptr, DirNames[i].second) == ptr)
        {
            ptr += strlen(DirNames[i].second);
            return DirNames[i].first;
        }
    }
    CHK_ERROR(false);
}

void matchNextData(char *&ptr)
{
    filterSpace(ptr);
    
    int i = 0;
    while (TokData[i] != 0)
    {
        CHK_ERROR(ptr[i] == TokData[i]);
        i++;
    }
    
    ptr += i;
}

int getNextInt(char *&ptr)
{
    filterSpace(ptr);
    CHK_ERROR(ptr[0] == '0');
    CHK_ERROR(ptr[1] == 'x');
    ptr += 2;
    
    int result = 0;
    while (1)
    {
        if (*ptr >= '0' && *ptr <= '9')
        {
            result = result*16;
            result = result+(*ptr)-'0';
            ptr++;
        }
        else if (*ptr >= 'a' && *ptr <= 'f')
        {
            result = result*16;
            result = result+(*ptr)-'a'+0xa;
            ptr++;
        }
        else
            break;
    }
    
    return result;
}

struct PE
{
    OP  op0 = OP_NOP;
    OP  op1 = OP_NOP;
    int imm0 = 0;
    int imm1 = 0;
    DIR arg00 = U0;
    DIR arg01 = D0;
    DIR arg02 = L0;
    DIR arg03 = R0;
    DIR arg10 = U1;
    DIR arg11 = D1;
    DIR arg12 = L1;
    DIR arg13 = R1;
    int data = 0;
    int u0tok0 = -1;
    int u0tok1 = -1;
    int u1tok0 = -1;
    int u1tok1 = -1;
    int d0tok0 = -1;
    int d0tok1 = -1;    
    int d1tok0 = -1;
    int d1tok1 = -1;
    int l0tok0 = -1;
    int l0tok1 = -1;
    int l1tok0 = -1;
    int l1tok1 = -1;    
    int r0tok0 = -1;
    int r0tok1 = -1;
    int r1tok0 = -1;
    int r1tok1 = -1;
    
    void setInst(int instNum, char *&ptr)
    {
        CHK_ERROR(instNum < 2);
        
        OP opcode = getNextOp(ptr);
        matchNextDelim(ptr, '(');
        
        if (instNum == 0)
            op0 = opcode;
        else
            op1 = opcode;
        
        if (hasNextInt(ptr))
        {
            int imm = getNextInt(ptr);
            if (instNum == 0)
                imm0 = imm;
            else
                imm1 = imm;
            matchNextDelim(ptr, ',');
        }
        
        int argNum = 0;
        while (1)
        {
            DIR dir = getNextDir(ptr);
            if (instNum == 0)
            {
                switch (argNum)
                {
                    case 0: arg00 = dir; break;
                    case 1: arg01 = dir; break;
                    case 2: arg02 = dir; break;
                    case 3: arg03 = dir; break;
                }
            }
            else
            {
                switch (argNum)
                {
                    case 0: arg10 = dir; break;
                    case 1: arg11 = dir; break;
                    case 2: arg12 = dir; break;
                    case 3: arg13 = dir; break;
                }
            }
            argNum++;
            
            if (*ptr == ')')
                break;
            
            matchNextDelim(ptr, ',');
        }
        
        matchNextDelim(ptr, ')');
    }
    
    void setData(char *&ptr)
    {
        matchNextData(ptr);
        matchNextDelim(ptr, '(');
        data = getNextInt(ptr);
        matchNextDelim(ptr, ')');
    }
    
    void setToken(char *&ptr)
    {
        DIR dir = getNextDir(ptr);
        matchNextDelim(ptr, '(');
        int tok = getNextInt(ptr);
        matchNextDelim(ptr, ')');
        
        switch (dir)
        {
            case U0: if (u0tok0 == -1) u0tok0 = tok; else u0tok1 = tok; break;
            case U1: if (u1tok0 == -1) u1tok0 = tok; else u1tok1 = tok; break;
            case D0: if (d0tok0 == -1) d0tok0 = tok; else d0tok1 = tok; break;
            case D1: if (d1tok0 == -1) d1tok0 = tok; else d1tok1 = tok; break;
            case L0: if (l0tok0 == -1) l0tok0 = tok; else l0tok1 = tok; break;
            case L1: if (l1tok0 == -1) l1tok0 = tok; else l1tok1 = tok; break;
            case R0: if (r0tok0 == -1) r0tok0 = tok; else r0tok1 = tok; break;
            case R1: if (r1tok0 == -1) r1tok0 = tok; else r1tok1 = tok; break;
        }
    }
    
    void setDesc(char *&ptr)
    {
        filterSpace(ptr);
        bool shouldMatchQuote = false;
        if (*ptr == '\"') {
            ptr++;
            IsInString = true;
            filterSpace(ptr);
            shouldMatchQuote = true;
        }
        
        bool numInsts = 0;
        while (true)
        {
            if (hasNextOp(ptr))
                setInst(numInsts++, ptr);
            else if (hasNextData(ptr))
                setData(ptr);
            else if (hasNextDir(ptr))
                setToken(ptr);
            else
                break;
        }
        
        filterSpace(ptr);
        if (shouldMatchQuote)
        {
            IsInString = false;
            CHK_ERROR(*ptr == '\"');
            ptr++;
            filterSpace(ptr);
        }
    }

    static void _initialize(PE *pe, int numOpSet, int numArgSet)
    {
        CHK_ERROR(numOpSet < 2 && numArgSet < 4);
    }
    
    static void _initialize(PE *pe, int numOpSet, int numArgSet, int data)
    {
        CHK_ERROR(numOpSet < 2 && numArgSet < 4);
        pe->data = data;
    }
    
    template <typename ...Args>
    static void _initialize(PE *pe, int numOpSet, int numImmSet, int numArgSet, DIR arg, Args... args)
    {
        CHK_ERROR(numOpSet >= 1 && numOpSet <= 2 && numArgSet < 4);
        if (numOpSet == 1)
        {
            if (numArgSet == 0)
                pe->arg00 = arg;
            else if (numArgSet == 1)
                pe->arg01 = arg;
            else if (numArgSet == 2)
                pe->arg02 = arg;
            else
                pe->arg03 = arg;
        }
        else
        {
            if (numArgSet == 0)
                pe->arg10 = arg;
            else if (numArgSet == 1)
                pe->arg11 = arg;
            else if (numArgSet == 2)
                pe->arg12 = arg;
            else
                pe->arg13 = arg;
        }
        _initialize(pe, numOpSet, numImmSet, numArgSet+1, args...);
    }
    
    template <typename ...Args>
    static void _initialize(PE* pe, int numOpSet, int numImmSet, int numArgSet, int imm, Args... args)
    {
        CHK_ERROR(numOpSet >=1 && numOpSet <= 2 && numImmSet < 1 && numArgSet == 0);
        if (numOpSet == 1)
            pe->imm0 = imm;
        else
            pe->imm1 = imm;
        _initialize(pe, numOpSet, numImmSet+1, 0, args...);
    }
    
    template <typename ...Args>
    static void _initialize(PE *pe, int numOpSet, int numImmSet, int numArgSet, OP opcode, Args... args)
    {
        CHK_ERROR(numOpSet < 2);
        if (numOpSet == 0)
            pe->op0 = opcode;
        else
            pe->op1 = opcode;
        _initialize(pe, numOpSet+1, 0, 0, args...);
    }
    
    template <typename ...Args>
    static void initialize(PE *pe, Args... args)
    {
        _initialize(pe, 0, 0, 0, args...);
    }
    
    template <typename ...Args>
    PE(Args... args)
    {
        initialize(this, args...);
    }
    
    void printOp(OP op)
    {
        for (int i = 0; i < sizeof(OpNames)/sizeof(OpNames[0]); i++)
        {
            if (OpNames[i].first == op)
            {
                printf("`OP_%s", OpNames[i].second);
                return;
            }
        }

        fprintf(stderr, "Illegal OP!\n");
        exit(0);
    }
    
    void printDir(DIR dir)
    {
        for (int i = 0; i < sizeof(DirNames)/sizeof(DirNames[0]); i++)
        {
            if (DirNames[i].first == dir)
            {
                printf("`DIR_%s", DirNames[i].second);
                return;
            }
        }

        fprintf(stderr, "Illegal Dir!\n");
        exit(0);
    }
    
    void printParameter()
    {
        printf("#(");
        
        printf(".OP0("); printOp(op0); printf("), ");
        printf(".Imm0(%d), ", imm0);
        printf(".Arg00("); printDir(arg00); printf("), ");
        printf(".Arg01("); printDir(arg01); printf("), ");
        printf(".Arg02("); printDir(arg02); printf("), ");
        printf(".Arg03("); printDir(arg03); printf("), ");
        
        printf(".OP1("); printOp(op1); printf("), ");
        printf(".Imm1(%d), ", imm1);
        printf(".Arg10("); printDir(arg10); printf("), ");
        printf(".Arg11("); printDir(arg11); printf("), ");
        printf(".Arg12("); printDir(arg12); printf("), ");
        printf(".Arg13("); printDir(arg13); printf("), ");
        
        printf(".DataLo(8'h%02x), ", data & 0xff);
        printf(".DataHi(8'h%02x), ", data >> 8);
        
        printf(".U0Tok0(%d), ", u0tok0);
        printf(".U0Tok1(%d), ", u0tok1);
        printf(".U1Tok0(%d), ", u1tok0);
        printf(".U1Tok1(%d), ", u1tok1);
        printf(".D0Tok0(%d), ", d0tok0);
        printf(".D0Tok1(%d), ", d0tok1);
        printf(".D1Tok0(%d), ", d1tok0);
        printf(".D1Tok1(%d), ", d1tok1);
        printf(".L0Tok0(%d), ", l0tok0);
        printf(".L0Tok1(%d), ", l0tok1);
        printf(".L1Tok0(%d), ", l1tok0);
        printf(".L1Tok1(%d), ", l1tok1);
        printf(".R0Tok0(%d), ", r0tok0);
        printf(".R0Tok1(%d), ", r0tok1);
        printf(".R1Tok0(%d), ", r1tok0);
        printf(".R1Tok1(%d)",   r1tok1);
        
        printf(")\n");
    }
    
    void addToken(DIR dir, int val)
    {
        if (val == -1)
        {
            fprintf(stderr, "invalid token!\n");
            exit(0);
        }
        
        switch (dir)
        {
            case U0:
                if (u0tok0 == -1)
                    u0tok0 = val;
                else if (u0tok1 == -1)
                    u0tok1 = val;
                else
                {
                    fprintf(stderr, "FIFO full!\n");
                    exit(0);
                }
                break;
            case U1:
                if (u1tok0 == -1)
                    u1tok0 = val;
                else if (u1tok1 == -1)
                    u1tok1 = val;
                else
                {
                    fprintf(stderr, "FIFO full!\n");
                    exit(0);
                }
                break;
            case D0:
                if (d0tok0 == -1)
                    d0tok0 = val;
                else if (d0tok1 == -1)
                    d0tok1 = val;
                else
                {
                    fprintf(stderr, "FIFO full!\n");
                    exit(0);
                }
                break;
            case D1:
                if (d1tok0 == -1)
                    d1tok0 = val;
                else if (d1tok1 == -1)
                    d1tok1 = val;
                else
                {
                    fprintf(stderr, "FIFO full!\n");
                    exit(0);
                }
                break;
            case L0:
                if (l0tok0 == -1)
                    l0tok0 = val;
                else if (l0tok1 == -1)
                    l0tok1 = val;
                else
                {
                    fprintf(stderr, "FIFO full!\n");
                    exit(0);
                }
                break;
            case L1:
                if (l1tok0 == -1)
                    l1tok0 = val;
                else if (l1tok1 == -1)
                    l1tok1 = val;
                else
                {
                    fprintf(stderr, "FIFO full!\n");
                    exit(0);
                }
                break;
            case R0:
                if (r0tok0 == -1)
                    r0tok0 = val;
                else if (r0tok1 == -1)
                    r0tok1 = val;
                else
                {
                    fprintf(stderr, "FIFO full!\n");
                    exit(0);
                }
                break;
            case R1:
                if (r1tok0 == -1)
                    r1tok0 = val;
                else if (r1tok1 == -1)
                    r1tok1 = val;
                else
                {
                    fprintf(stderr, "FIFO full!\n");
                    exit(0);
                }
                break;
        }
    }
};

std::vector<std::vector<PE>> readFile(FILE *fp)
{
    /* 1MB should be enough */
    static char desc[1000000];
    
    int numByteRead = fread(desc, 1, sizeof(desc), fp);
    CHK_ERROR(numByteRead > 0 && numByteRead < sizeof(desc)-1);
    desc[numByteRead] = 0;
    
    char *ptr = desc;
    
    int width = 0;
    X = 0;
    Y = 0;
    std::vector<std::vector<PE>> result;
    
    while (1)
    {
        result.push_back(std::vector<PE>());
        while (1)
        {
            result[Y].push_back(PE());
            result[Y][X].setDesc(ptr);
            X++;
            if (Y == 0)
                width = X;
            
            filterSpace(ptr);
            if (*ptr == ',')
                matchNextDelim(ptr, ',');
            else
                break;
        }
        
        CHK_ERROR(result[Y].size() == width);
        
        if (hasNextLine(ptr))
        {
            Y++;
            X = 0;
            matchNextLine(ptr);
            if (!hasNextDesc(ptr))
                break;
        }
        else
            break;
    }
    
    return result;
}

int main(int argc, char *argv[])
{
    FILE *fp = fopen(argv[1], "rb");
    CHK_ERROR(fp != NULL);
    
    std::vector<std::vector<PE>> pes = readFile(fp);
    
    fclose(fp);
    
    int width = pes[0].size();
    int height = pes.size();
    
    printf("`define DATA_SIZE   8\n");
    printf("`include \"pe2.v\"\n\n");
    
    printf("module pe2_test;\n");
    printf("    reg [31:0] clkReg;\n");
    printf("    reg [`DATA_SIZE*2-1:0] zeroData;\n");
    printf("    reg zeroFlag;\n\n");
    
    printf("    wire clk = clkReg[0:0];\n\n");
    
    /* The output of PEs, can be used in bunches */
    printf("    wire [7:0][`DATA_SIZE*2-1:0] outData [%d:0][%d:0];\n", height-1, width-1);
    printf("    wire [7:0] outDataReady [%d:0][%d:0];\n", height-1, width-1);
    printf("    wire [7:0] readInData [%d:0][%d:0];\n\n", height-1, width-1);
    
    /* The input of PEs, should be gathered from output of other PEs or from the zero register */
    printf("    wire [7:0][`DATA_SIZE*2-1:0] inData [%d:0][%d:0];\n", height-1, width-1);
    printf("    wire [7:0] inDataReady [%d:0][%d:0];\n", height-1, width-1);
    printf("    wire [7:0] readOutData [%d:0][%d:0];\n\n", height-1, width-1);
    
    /* U0 = 0, U1 = 1, D0 = 2, D1 = 3, L0 = 4, L1 = 5, R0 = 6, R1 = 7 */
    int xOffset[8] = { 0,  0,  0,  0, -1, -2,  1,  2};
    int yOffset[8] = {-1, -2,  1,  2,  0,  0,  0,  0};
    int invDir[8] = {2, 3, 0, 1, 6, 7, 4, 5};   // my U0 is the D0 of the PE above me
    
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            /* Gather inputs from output of other PEs */
            for (int i = 0; i < 8; i++)
            {
                int srcX = x+xOffset[i];
                int srcY = y+yOffset[i];
                
                if (srcX >= 0 && srcX < width && srcY >= 0 && srcY < height)
                {
                    printf("    assign inData[%d][%d][%d][`DATA_SIZE*2-1:0] = outData[%d][%d][%d][`DATA_SIZE*2-1:0];\n", y, x, i, srcY, srcX, invDir[i]);
                    printf("    assign inDataReady[%d][%d][%d] = outDataReady[%d][%d][%d];\n", y, x, i, srcY, srcX, invDir[i]);
                    printf("    assign readOutData[%d][%d][%d] = readInData[%d][%d][%d];\n", y, x, i, srcY, srcX, invDir[i]);
                }
                else
                {
                    printf("    assign inData[%d][%d][%d][`DATA_SIZE*2-1:0] = zeroData[`DATA_SIZE*2-1:0];\n", y, x, i);
                    printf("    assign inDataReady[%d][%d][%d] = zeroFlag;\n", y, x, i);
                    printf("    assign readOutData[%d][%d][%d] = zeroFlag;\n", y, x, i);
                }
            }
            printf("\n");
            
            /* Declare the PE */
            printf("    pe2");
            pes[y][x].printParameter();
            printf("    pe_%d%c(clk, inData[%d][%d], inDataReady[%d][%d], readInData[%d][%d], outData[%d][%d], outDataReady[%d][%d], readOutData[%d][%d]);\n\n",
                   y+1, x+'A', y, x, y, x, y, x, y, x, y, x, y, x);
        }
    }
    
    /* Fill zeroData, zeroFlag, and let the clock starts */
    /* We may not let postive edge occur at time 0 since the PEs also have initialization blocks */
    printf("    initial begin\n");
    printf("        clkReg = 0;\n");
    printf("        zeroData = 0;\n");
    printf("        zeroFlag = 0;\n\n");
    printf("    #600 $finish;\n");
    printf("    end\n\n");
    
    printf("    always begin\n");
    printf("    #1  clkReg = clkReg+1;\n");
    printf("        $display(\"clock: %cd\", clkReg);\n", '%');
    printf("    end\n");
    
    printf("endmodule\n");
}