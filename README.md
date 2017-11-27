# Hanatachi

 > Mini implementación de ActivityPub en Ruby

 ActivityPub es el estandar de la web social federada. Este protocolo nos permite dar vida a una red distribuida de nodos donde sus usuarios independientemente del servidor o la instalación en la que están registrados pueden interactuar e intercambiar mensajes. Una red que dada su estructura distribuida es mucho más resiliente y liberadora que los grandes silos centralizadores como Twitter o Facebook.

 Durante esta charla montaremos desde cero una mini implementación básica de ActivityPub. En el proceso nos familiarizaremos con los componentes y requerimientos básicos para la implementación de este protocolo en cualquier proyecto web que estés desarrollando.

 # Getting started

 ```
 https://github.com/ortegacmanuel/hanatachi.git
 cd hanatachi
 git checkout miniactivitypub
 bundle install
 ```

 # Testing the federation

 In a separate terminals start bob's and alice's servers

 ```
 ruby app.rb 1111 bob
 ```

 ```
 ruby app.rb 2222 alice
 ```

In other terminal start pry and load the client class

```
 pry
pry(main)> require_relative 'client'
=> true
```
Create the bob's client

```
pry(main)> bob = Client.new('http://localhost:1111/@bob')
=> #<Client:0x005584e39f09f8 @user_id="http://localhost:1111/@bob">
```

Create the alice's client

[3] pry(main)> alice = Client.new('http://localhost:2222/@alice')
=> #<Client:0x005584e3a8f850 @user_id="http://localhost:2222/@alice">

Alicie sends a message to Bob

[4] pry(main)> alice.publish('hola, ¿Vamos al cine esta noche?', [bob.user_id])
=> "OK. Actividad agregada al outbox de alice!"

Bob responds to Alice

```
pry(main)> bob.publish('claro!, cuenta conmigo!', [alice.user_id])
=> "OK. Actividad agregada al outbox de bob!"
```

In the server's terminals you can see the state of Bob's and Alice's inboxes and outboxes
