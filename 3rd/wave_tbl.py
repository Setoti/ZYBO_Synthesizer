import math

with open("SinTbl.coe","w") as f:

    # write header
    f.write('memory_initialization_radix=16;\n')
    f.write('memory_initialization_vector=\n')

    for i in range(2048):

        # Calculate sine wave
        sin_val = 16384*math.sin(2.0*math.pi*i/2048)
        print(sin_val)

        # change unsigned shot type
        sin_val = round(sin_val)
        if(sin_val<0):
            sin_val = sin_val+32768 # 1-15bitを求める
            sin_val += 32768 # 16bit目を1にする

        # write coe file
        if i != 2047:
            f.write('{:04x},\n'.format(sin_val))
        else:
            f.write('{:04x};\n'.format(sin_val))

    
