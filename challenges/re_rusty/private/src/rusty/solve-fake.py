from z3 import *



flag = [BitVec("c" + str(d),8) for d in range(55)]


s = Solver()

s.add(flag[0] == 106)
s.add(flag[1] == 99)
s.add(flag[2] == 116)
s.add(flag[3] == 102)
s.add(flag[4] == 123)
s.add(flag[54] == 125)

correct = [325,324,315,283,251,251,288,316,337,322, 327, 315, 321, 300, 320, 281, 281, 278, 327, 349, 323, 309, 306, 312, 310, 304, 314, 330, 329, 323, 322, 318, 308, 250, 242, 217, 230, 210, 209, 214, 215, 211, 212, 169, 137, 99, 99, 191, 264, 330]

for i in range(50):
    k = (5 + i) % 55
    l = (6 + i) % 55
    m = (7 + i) % 55

    s.add(correct[i] == (flag[k] + flag[l] + flag[m]))

print(s.check())

r = s.model()

flag_txt = z3.Concat(*flag)
print(r.evaluate(flag_txt).as_long().to_bytes(55, 'big'))
