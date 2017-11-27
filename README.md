# Hanatachi

![Miniactivitypub](https://raw.githubusercontent.com/ortegacmanuel/hanatachi/miniactivitypub/miniactivitypub.png)

 > Mini implementación de ActivityPub en Ruby

 ActivityPub es el estandar de la web social federada. Este protocolo nos permite dar vida a una red distribuida de nodos donde sus usuarios independientemente del servidor o la instalación en la que están registrados pueden interactuar e intercambiar mensajes. Una red que dada su estructura distribuida es mucho más resiliente y liberadora que los grandes silos centralizadores como Twitter o Facebook.

 Durante esta charla montaremos desde cero una mini implementación básica de ActivityPub. En el proceso nos familiarizaremos con los componentes y requerimientos básicos para la implementación de este protocolo en cualquier proyecto web que estés desarrollando.

 # Getting started

 ```
 git clone https://github.com/ortegacmanuel/hanatachi.git
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
require_relative 'client'
```
Create the bob's client

```
bob = Client.new('http://localhost:1111/@bob')
```

Create the alice's client

```
alice = Client.new('http://localhost:2222/@alice')
```

Alicie sends a message to Bob

```
alice.publish('hola, ¿Vamos al cine esta noche?', [bob.user_id])
```

Bob responds to Alice


```
bob.publish('claro!, cuenta conmigo!', [alice.user_id])
```

In the server's terminals you can see the state of Bob's and Alice's inboxes and outboxes
