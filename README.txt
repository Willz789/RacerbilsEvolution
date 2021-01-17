Jeg har lavet et program, jeg har en selvvalgt mængde af biler, som styres efter et neuralt netværk, som er 
indbygget i et sensorsystem. Der er lavet en genetisk algoritme som bygger en ny generation af biler efter 
en bestemt mængde frames. Jeg har valgt at arbejde med frames og ikke millisekunder, da frames fjerner den negative
effekt fra lag. Jeg har samtidigt med lavet den sådan så, at jeg selv vælger, hvor mange sensorer der skal være på 
bilerne. Jeg har også valgt at tegne min egen bane, da jeg i starten havde nogle problemer med, at billedets farver
var skæve fra helt hvid og sort i starten (Burde ikke gøre nogen forskel).
Den genetiske algoritme er bygget til at vælge biler efter hurtigste runde, mindst tid uden for banens grænser og 
mindst tid i den forkerte retning. Jeg har også valgt at bruge bias til mit neurale netværk.
Jeg lavede den også med en timer der siger, hvornår den næste genetiske algoritme starter, og hvis man trykker på 
skærmen, så kan man se en graf der viser de bedste runder pr. generation.
