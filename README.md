# lua-processor
A Factorio mod that lets you run LUA programs ingame.  
This is can be platform for developing custom signal processors, object controllers and etc.  
Custom programs defined in 'programs' folder, to add new - place your program file in that folder and run 'programs\install.bat'. 
Program 'none.lua' can be used as template for new programs. As example you can use 'storage-controller.lua'.

# Custom 'storage-controller' program in action:
Produces specified products in the required quantity using thresholds ...  
Program required two additional modules: ram for production list/priority, io module for reading storage state - both must be placed around cpu module. 
Production control signal out from cpu module to "crafting_combinator" module. Program defined in file "programs\storage-controller.lua"
</br>
<details>
  <summary>blueprint for 0.15.x :</summary>
0eNrtWk1zozgQ/S+cYQr0BXbteU+7v2Aq5cKg2KoBRAk8s6mU//sKiG3GkaA749xySQoCr1ut7tePVl6DfXWSrVFNH2xfA1Xopgu231+DTh2avBru9S+tDLaB6mUdhEGT18NV3nWy3leqOUR1XhxVIyMSnMNANaX8L9gm53AVojd507Xa9NFeVv3sZXJ+CgPZ9KpXcnJmvHjZNad6L41F92GEQas7+5puBqsWKrKPvthfqUUvlZHF9Dc2uHcHStCgfB2UokHFOigDg7oxiQOTYzH52YEiwCgU7FkKxiRgzGw5j33e2s0ILK4ak1lW1oLRjSqiQpnipIYUfmdpc7XUtZXqe3vvHTr/xsEJlcTgcDBwOBJ4QXFwliaIgnqLLwWgIiqKOFGFC5Wh6xSCytGoDBCBW5E9510fqaaTxplXCMxbkRUmf+5tOewKXe9Vk/fa7P7+95/dtU1EZd7nUWt0rwda301QXutDnGxTsZVS7fbymP9U2gxPPKvKOg3qNWiXimI3IOxK2Y19pdCnob3Ra4dhgPb0Eau1Lk+V9Nvl5ycXbSbZotXLveh2bzHc82ofg99Ml93waDL8OBgpm3lnVaV1jg7eudzbYOkBkHIkxoIC2IHAiUw4PXWVMSGPL470qzigxUEolO+EuwRcmOzPCy51ZyWi4ETiKThyaxzVaYxiIbtOm6hoT47esZk8Sf48mZya5rJTyUzdP50R6yTCt85bK+vqvKqiyb613upKOlaaTSslHutGlve2GZ3ZHW+w4evC7Sd3POt2PEVrmwTAXhkalQBQZxK0z4sf0ZQPC3V0ESPEk1BvqWErpimv7z0r0/W7NdrQbWtNt1XeyymzGuvTkFw8jofLus3NWG7b4K/gDN9mOpZS+FuuX5LVY/3J9bl2a0q/tC5lExXHga68IUpc2UETdMSJM0nEo+OvbG1/QvTJxlk4K9sxd8a5GeQujP74xe7wuUApUj0T5w4zYJ4spgkHr4/A1wf+OoAzCE1njmojj/rUyWifd6rwfXXGCIb2kSzNoEvhS1u1gaKwBRQWI0VIsi5CWIKcQmQ3aOQUghGPoDB57RUU8QPE6cS4Rb6v5ExJjHSDmBQuypI5GAGAjbRzkLmJfh2lrDxIFIJ0SQI3BPvQDNQBxAFAJ/uoORj7crkEJQBQvye4Gyd1a3VGPXmmtKuHxliu8CpJxpBKcmLUBKEw0rseR8TdjUGDhF4FHMK+tRlHkkJ8XQiWE8Cdgly3aaX5sBQHCSFJuCZOwZgbHJkDVs7h04wM6iaHDzM2YEzyWYO+r1HG+iiD00fN+Sjm+zvJ3svzEDaJ4AxX0YCpOOfIQyLqdAypcwEyl6c4pegUihwpWiF+bZAtYUL+wGGViD9r0vnFDuvsIJJHDSWpa4wAnNUxqFIRBHkwy9bbk6CA41LydlzqPoFmSHZhThQOreJ0AUQgpQvg+FekyOUJp2cZ8hBZrNO6wB4SATDTGHmcA8FMkLvyDtOK/JEjtrN/nQmDn5bGpgcYI5zzLE7S8/l/axIDHQ== 
</details>
</br>
Mods required:</br>
crafting_combinator_0.9.2</br>
Warehousing v15_0.0.13</br>

![Alt text](/README-1.png?raw=true "")
 
# Thanks
 * YPetrermann - programmable-controllers
 * James O'Farrell / Aaron Becker - LuaCombinator
 * LuziferSenpai and theRustyKnife - crafting_combinator
 * & many other mod authors ...
 
## Donation
If this project help you reduce time to develop, you can give me a cup of coffee :) 

[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=9LN5B389QKPB2&lc=US) 