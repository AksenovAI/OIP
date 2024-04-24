import RPi.GPIO as GPIO
import matplotlib.pyplot as plt
import time
#функция перевода системы счисления из 10 в 2
def dec2bin(num):
    return [int(elem) for elem in bin(num)[2:].zfill(8)]
#функция перевода аналогового значения в цифровое
def adc():
    k = 0
    for i in range(7, -1, -1):
        k += 2**i
        val1 = dec2bin(k)
        GPIO.output(dac, val1)
        time.sleep(0.01)
        val2 = GPIO.input(comp)
        if val2 == 1:
            k -= 2**i
    return k
#вывод на DAC
def num2_dac_leds(value):
    signal = dec2bin(value)
    GPIO.output(dac, signal)
    return signal

dac = [8, 11, 7, 1, 0, 5, 12, 6]
leds = [2, 3, 4, 17, 27, 22, 10, 9]
comp = 14
troyka = 13
bits = len(dac)
levels = 2 ** bits
maxV = 3.3

GPIO.setmode(GPIO.BCM)

GPIO.setup(troyka, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(dac, GPIO.OUT)
GPIO.setup(comp, GPIO.IN)

GPIO.output(troyka, 0)

data_volts = []
data_times = []

try:
    #начало эксперимента
    start_time = time.time()
    val = 0
    #подаем напряжение на конденсатор
    GPIO.output(troyka, 1)
    print("charging\n")
    #отслеживаем процесс зарядки
    while(val < 206):
        val = adc()
        print(" volts - {:3}  val {}".format(val / levels * maxV, val))
        num2_dac_leds(val)
        data_volts.append(val)
        data_times.append(time.time() - start_time)
    #прекращаем подачу напряжения
    GPIO.output(troyka, 0)
    print("discharging\n")
    #отслеживаем разрядку
    while(val > 178):
        val = adc()
        print(" volts - {:3} val {}".format(val/levels * maxV, val))
        num2_dac_leds(val)
        data_volts.append(val)
        data_times.append(time.time() - start_time)

    end_time = time.time()
    #запись в файл
    with open("./settings.txt", "w") as file:
        file.write(str((end_time - start_time) / len(data_volts)))
        file.write(("\n"))
        file.write(str(maxV / 256))
    #вывод графика
    print(end_time - start_time, " secs\n", len(data_volts) / (end_time - start_time), "\n", maxV / 256)

finally:
    GPIO.output(dac, GPIO.LOW)
    GPIO.output(troyka, GPIO.LOW)
    GPIO.cleanup()

data_times_str = [str(item) for item in data_times]
data_volts_str = [str(item) for item in data_volts]

with open("data.txt", "w") as file:
    file.write("\n".join(data_volts_str))

plt.plot(data_times, data_volts)
plt.show()