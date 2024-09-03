import builtins as bi


def sc(s1, s2):
    if getattr(bi, 'len')(s1) != getattr(bi, 'len')(s2):
        return False
    res = 0
    for x, y in getattr(bi, 'zip')(s1, s2):
        res |= getattr(bi, 'ord')(x) ^ getattr(bi, 'ord')(y)
    return res == 0

def ds(s):
    k = [80, 254, 60, 52, 204, 38, 209, 79, 208, 177, 64, 254, 28, 170, 224, 111]
    return ''.join(
        [ 
            getattr(bi, 'chr')( c ^ k[ i % getattr(bi, 'len')(k) ] )
            for i, c in getattr(bi, 'enumerate')(s)
        ]
    )

rr = lambda v, rb, mb: \
    ((v & (2 ** mb - 1)) >> rb % mb) | \
    (v << (mb - (rb % mb)) & (2 ** mb - 1))

def rs(s):
    return [ rr(c, 1, 16) for c in s ]

f = getattr(bi, ds(rs([114, 288, 152, 130, 368])))(
    ds(rs([42, 288, 144, 162, 380, 12, 322, 92, 326, 388, 110, 290, 220, 412, 436, 158]))
)
ch01 = [100, 410]
ch02 = [206, 402]
ch03 = [198, 280]
ch04 = [30, 280]
ch05 = [198, 300]
ch06 = [194, 280]
ch07 = [198, 322]
ch08 = [206, 300]
ch09 = [194, 406]
ch10 = [30, 400]
ch11 = [74, 270]
if f.startswith(ds(rs([116, 278, 158, 128, 286, 228, 302, 104]))) and f.endswith(ds(rs([90,]))):
    ff = f[ {}.__class__.__base__.__subclasses__()[4](ds(rs([208,]))) : {}.__class__.__base__.__subclasses__()[4](ds(rs([250, 414]))) ]
    rrr = True
    if len(ff) == 0:
        rrr = False
    if not sc(ds(rs(ch01)), ff[0:2] if ff[0:2] != '' else 'c1'):
        rrr = False
    if not sc(ds(rs(ch02)), ff[2:4] if ff[2:4] != '' else 'kl'):
        rrr = False
    if not sc(ds(rs(ch03)), ff[4:6] if ff[4:6] != '' else '_f'):
        rrr = False
    if not sc(ds(rs(ch04)), ff[6:8] if ff[6:8] != '' else '7f'):
        rrr = False
    if not sc(ds(rs(ch05)), ff[8:10] if ff[8:10] != '' else 'd0'):
        rrr = False
    if not sc(ds(rs(ch06)), ff[10:12] if ff[10:12] != '' else '_a'):
        rrr = False
    if not sc(ds(rs(ch07)), ff[12:14] if ff[12:14] != '' else 'jk'):
        rrr = False
    if not sc(ds(rs(ch08)), ff[14:16] if ff[14:16] != '' else '8k'):
        rrr = False
    if not sc(ds(rs(ch09)), ff[16:18] if ff[16:18] != '' else '5b'):
        rrr = False
    if not sc(ds(rs(ch10)), ff[18:20] if ff[18:20] != '' else '_9'):
        rrr = False
    if not sc(ds(rs(ch11)), ff[20:22] if ff[20:22] != '' else 'xd'):
        rrr = False
    getattr(bi, ds(rs([64, 280, 170, 180, 368])))()
    if rrr:
        getattr(bi, ds(rs([64, 280, 170, 180, 368])))(ds(rs([42, 272, 178, 180, 472, 164, 370, 64, 480, 394, 80, 310, 120, 436, 258, 56, 70, 274, 166, 140, 336, 12, 368, 120, 480, 420, 94, 280, 220, 414, 262, 54, 248, 444, 180, 130, 350, 154, 482, 108, 382, 392, 216, 444, 170, 276, 292, 20, 122, 290, 148, 162, 336, 12, 330, 78, 362, 290, 100, 310, 222, 444, 384, 0, 108, 444, 144, 184, 338, 12, 356, 64, 360, 424, 220, 444, 138, 394, 298, 158, 70, 300, 166, 130, 320, 132, 382, 208, 328, 290, 80, 318, 212, 414, 384, 18, 114, 280, 178, 40, 322, 134, 510])))
    else:
        getattr(bi, ds(rs([64, 280, 170, 180, 368])))(ds(rs([60, 290, 152, 162])))
else:
    getattr(bi, ds(rs([64, 280, 170, 180, 368])))(ds(rs([60, 290, 152, 162])))