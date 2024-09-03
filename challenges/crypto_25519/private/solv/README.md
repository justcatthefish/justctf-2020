## Task idea

crypto, easy

[Bug z Monero](https://jonasnick.github.io/blog/2017/05/23/exploiting-low-order-generators-in-one-time-ring-signatures/) z 2017.

Implementacja ,,one-time ring signatures". Działa jak zwykły podpis, który jednakże może być wykonany tylko raz, tzn. system/serwer ma możliwość sprawdzenia czy wiadomość danym kluczem była już podpisana. U nas, dla prostoty, ring size == 1 i wiadomość jest stała. Zadanie polega na podpisaniu jej kilka razy tym samym kluczem.

Błąd w zadaniu (i w Monero kiedyś) bierze się z wykorzystania krzywej Curve25519, która ma małą podgrupę rzędu 8. Szczegóły w linku.
 