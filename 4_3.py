import RPi.GPIO as GPIO
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
n = 24
GPIO.setup(n, GPIO.OUT)
p = GPIO.PWM(n,1000)
p.start(0)
try:
    while True:
        f = int(input())
        p.ChangeDutyCycle(f)
        print(3.3 * f / 100)
finally:
    p.stop()
    GPIO.output(n, 0)
    GPIO.cleanup()
