import RPi.GPIO as GPIO\

GPIO.setwarnings(False)
dac = [8, 11, 7, 1, 0, 5, 12, 6]
led = [2, 3, 4, 17, 27, 22, 10, 9]
GPIO.setmode(GPIO.BCM)
GPIO.setup(dac, GPIO.OUT)
GPIO.setup(led, GPIO.OUT)
def dec2bin(num): return [int(element) for element in bin(num)[2:].zfill(8)]
try:
    while True:
        num = input("Type a number from 0 to 255\n")
        try:
            num = int(num)
            if 0 <= num <= 255:
                GPIO.output(dac, dec2bin(num))
                volt = float(num) * 3.3 / 256
                print(f"Output voltage is {volt} volt")
            elif num < 0:
                print("incorrect number: negative number")
            elif num > 255:
                print("incorrect number: number is over 255")
        except Exception:
            if num == 'q': break
finally:
    GPIO.output(dac, 0)
    GPIO.cleanup()



