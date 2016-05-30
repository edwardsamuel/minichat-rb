# minichat-rb

Simple chat client-server for demonstrating Ruby Socket. This was tested using Ruby 2.2.1 on Ubuntu 14.04 and might be compatible with Ruby 2.0 and above.

### How to run

Install required dependencies:

```
bundle install
```

Start the server:

```
ruby -Ilib ./bin/minichat-server
```

Start the client:

```
ruby -Ilib ./bin/minichat-server
```

### Command on client

After you login, you can send either:

1. Broadcast message

```
broadcast <Message_Body>
```

2. Chat one-on-one

```
chat <Recipient_Nick_Name> <Message_Body>
```