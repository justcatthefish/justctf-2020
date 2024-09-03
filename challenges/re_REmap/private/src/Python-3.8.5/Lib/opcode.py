
"""
opcode module - potentially shared between dis and other modules which
operate on bytecodes (e.g. peephole optimizers).
"""

__all__ = ["cmp_op", "hasconst", "hasname", "hasjrel", "hasjabs",
           "haslocal", "hascompare", "hasfree", "opname", "opmap",
           "HAVE_ARGUMENT", "EXTENDED_ARG", "hasnargs"]

# It's a chicken-and-egg I'm afraid:
# We're imported before _opcode's made.
# With exception unheeded
# (stack_effect is not needed)
# Both our chickens and eggs are allayed.
#     --Larry Hastings, 2013/11/23

try:
    from _opcode import stack_effect
    __all__.append('stack_effect')
except ImportError:
    pass

cmp_op = ('<', '<=', '==', '!=', '>', '>=', 'in', 'not in', 'is',
        'is not', 'exception match', 'BAD')

hasconst = []
hasname = []
hasjrel = []
hasjabs = []
haslocal = []
hascompare = []
hasfree = []
hasnargs = [] # unused

opmap = {}
opname = ['<%r>' % (op,) for op in range(256)]

def def_op(name, op):
    opname[op] = name
    opmap[name] = op

def name_op(name, op):
    def_op(name, op)
    hasname.append(op)

def jrel_op(name, op):
    def_op(name, op)
    hasjrel.append(op)

def jabs_op(name, op):
    def_op(name, op)
    hasjabs.append(op)

# Instruction opcodes for compiled code
# Blank lines correspond to available opcodes

def_op('POP_TOP', 64)
def_op('ROT_TWO', 9)
def_op('ROT_THREE', 71)
def_op('DUP_TOP', 60)
def_op('DUP_TOP_TWO', 54)
def_op('ROT_FOUR', 56)

def_op('NOP', 52)
def_op('UNARY_POSITIVE', 26)
def_op('UNARY_NEGATIVE', 78)
def_op('UNARY_NOT', 27)

def_op('UNARY_INVERT', 81)

def_op('BINARY_MATRIX_MULTIPLY', 70)
def_op('INPLACE_MATRIX_MULTIPLY', 88)

def_op('BINARY_POWER', 12)
def_op('BINARY_MULTIPLY', 4)

def_op('BINARY_MODULO', 68)
def_op('BINARY_ADD', 29)
def_op('BINARY_SUBTRACT', 11)
def_op('BINARY_SUBSCR', 17)
def_op('BINARY_FLOOR_DIVIDE', 67)
def_op('BINARY_TRUE_DIVIDE', 84)
def_op('INPLACE_FLOOR_DIVIDE', 86)
def_op('INPLACE_TRUE_DIVIDE', 23)

def_op('GET_AITER', 76)
def_op('GET_ANEXT', 82)
def_op('BEFORE_ASYNC_WITH', 19)
def_op('BEGIN_FINALLY', 10)
def_op('END_ASYNC_FOR', 59)
def_op('INPLACE_ADD', 50)
def_op('INPLACE_SUBTRACT', 65)
def_op('INPLACE_MULTIPLY', 79)

def_op('INPLACE_MODULO', 6)
def_op('STORE_SUBSCR', 3)
def_op('DELETE_SUBSCR', 28)
def_op('BINARY_LSHIFT', 25)
def_op('BINARY_RSHIFT', 16)
def_op('BINARY_AND', 62)
def_op('BINARY_XOR', 85)
def_op('BINARY_OR', 75)
def_op('INPLACE_POWER', 73)
def_op('GET_ITER', 72)
def_op('GET_YIELD_FROM_ITER', 83)

def_op('PRINT_EXPR', 22)
def_op('LOAD_BUILD_CLASS', 2)
def_op('YIELD_FROM', 87)
def_op('GET_AWAITABLE', 5)

def_op('INPLACE_LSHIFT', 1)
def_op('INPLACE_RSHIFT', 53)
def_op('INPLACE_AND', 20)
def_op('INPLACE_XOR', 63)
def_op('INPLACE_OR', 57)
def_op('WITH_CLEANUP_START', 66)
def_op('WITH_CLEANUP_FINISH', 55)
def_op('RETURN_VALUE', 89)
def_op('IMPORT_STAR', 15)
def_op('SETUP_ANNOTATIONS', 24)
def_op('YIELD_VALUE', 61)
def_op('POP_BLOCK', 77)
def_op('END_FINALLY', 51)
def_op('POP_EXCEPT', 69)

HAVE_ARGUMENT = 90              # Opcodes from here have an argument:

name_op('STORE_NAME', 125)       # Index in name list
name_op('DELETE_NAME', 136)      # ""
def_op('UNPACK_SEQUENCE', 106)   # Number of tuple items
jrel_op('FOR_ITER', 98)
def_op('UNPACK_EX', 144)
name_op('STORE_ATTR', 126)       # Index in name list
name_op('DELETE_ATTR', 95)      # ""
name_op('STORE_GLOBAL', 156)     # ""
name_op('DELETE_GLOBAL', 110)    # ""
def_op('LOAD_CONST', 97)       # Index in const list
hasconst.append(97)
name_op('LOAD_NAME', 155)       # Index in name list
def_op('BUILD_TUPLE', 91)      # Number of tuple items
def_op('BUILD_LIST', 154)       # Number of list items
def_op('BUILD_SET', 153)        # Number of set items
def_op('BUILD_MAP', 133)        # Number of dict entries
name_op('LOAD_ATTR', 132)       # Index in name list
def_op('COMPARE_OP', 115)       # Comparison operator
hascompare.append(115)
name_op('IMPORT_NAME', 108)     # Index in name list
name_op('IMPORT_FROM', 94)     # Index in name list

jrel_op('JUMP_FORWARD', 102)    # Number of bytes to skip
jabs_op('JUMP_IF_FALSE_OR_POP', 158) # Target byte offset from beginning of code
jabs_op('JUMP_IF_TRUE_OR_POP', 103)  # ""
jabs_op('JUMP_ABSOLUTE', 150)        # ""
jabs_op('POP_JUMP_IF_FALSE', 130)    # ""
jabs_op('POP_JUMP_IF_TRUE', 131)     # ""

name_op('LOAD_GLOBAL', 113)     # Index in name list

jrel_op('SETUP_FINALLY', 93)   # Distance to target address

def_op('LOAD_FAST', 141)        # Local variable number
haslocal.append(141)
def_op('STORE_FAST', 137)       # Local variable number
haslocal.append(137)
def_op('DELETE_FAST', 114)      # Local variable number
haslocal.append(114)

def_op('RAISE_VARARGS', 111)    # Number of raise arguments (1, 2, or 3)
def_op('CALL_FUNCTION', 122)    # #args
def_op('MAKE_FUNCTION', 96)    # Flags
def_op('BUILD_SLICE', 124)      # Number of items
def_op('LOAD_CLOSURE', 161)
hasfree.append(161)
def_op('LOAD_DEREF', 147)
hasfree.append(147)
def_op('STORE_DEREF', 142)
hasfree.append(142)
def_op('DELETE_DEREF', 112)
hasfree.append(112)

def_op('CALL_FUNCTION_KW', 107)  # #args + #kwargs
def_op('CALL_FUNCTION_EX', 138)  # Flags

jrel_op('SETUP_WITH', 145)

def_op('LIST_APPEND', 116)
def_op('SET_ADD', 151)
def_op('MAP_ADD', 152)

def_op('LOAD_CLASSDEREF', 146)
hasfree.append(146)

def_op('EXTENDED_ARG', 109)
EXTENDED_ARG = 109

def_op('BUILD_LIST_UNPACK', 101)
def_op('BUILD_MAP_UNPACK', 157)
def_op('BUILD_MAP_UNPACK_WITH_CALL', 92)
def_op('BUILD_TUPLE_UNPACK', 148)
def_op('BUILD_SET_UNPACK', 104)

jrel_op('SETUP_ASYNC_WITH', 160)

def_op('FORMAT_VALUE', 149)
def_op('BUILD_CONST_KEY_MAP', 105)
def_op('BUILD_STRING', 100)
def_op('BUILD_TUPLE_UNPACK_WITH_CALL', 143)

name_op('LOAD_METHOD', 90)
def_op('CALL_METHOD', 135)
jrel_op('CALL_FINALLY', 163)
def_op('POP_FINALLY', 162)

del def_op, name_op, jrel_op, jabs_op