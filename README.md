# FSINCOS-i287
Náhrada instrukce FSINCOS pro koprocesor i287.

Jedinou goniometrickou funkci co umi matematicky koprocesor i287 je FPTAN. 
FSINCOS je podporovana az od i387. 
Jak spocitat sinus a kosinus pres tangentu?

     tan = sin / cos
     
     pythagorova veta, jednotkova kruznice a podobnost v trojuhelniku:
     
     1             L
     + ----------+   
     |       1 / |
     |       +   t
     |     / s   a
     |   /   i   n
     | /     n   |
     0 -cos--+---+ 1
     
     tan / 1 = sin / cos
     sin / 1 = tan / 0L
     cos / 1 = 1 / 0L
     0L*0L = tan*tan + 1*1

I have no idea whether I correctly implemented FWAIT for 8087
