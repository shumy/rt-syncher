export default class Client {
  /* private
    _id: number
    _serverURL: url
    _continuousOpen: bool

    _token: string

    _replyTimeOut: number
    _replyCallbacks: <url+id: (msg) => void>

    _sock: (WebSocket | SockJS)
    _onMessage: (msg) => void
  */

  constructor(serverURL) {
    let _this = this;

    _this._id = 0;
    _this._serverURL = serverURL;

    _this._token = null;

    _this._replyTimeOut = 3000;
    _this._replyCallbacks = {}

    _this.connect();
  }

  connect() {
    let _this = this;

    _this._continuousOpen = true;
    _this._open(() => {});
  }

  disconnect() {
    let _this = this;

    _this._continuousOpen = false;
    if (_this._sock) {
      _this._sendClose();
    }
  }

  login(user, password) {
    let _this = this;

    let loginMsg = { cmd: 'login', from: user, to: 'serv:session', service: 'serv:session' };
    _this.sendMessage(loginMsg, (reply) => {
      if (reply.cmd === 'ok') {
        _this._token = reply.body;
        _this._publish({ cmd: 'status', body: 'session' });
      } else {
        _this._publish({ cmd: 'status', body: reply.body });
      }
    });
  }

  logout() {
    let _this = this;
    let logoutMsg = { cmd: 'logout', to: 'serv:session' };
    _this.sendMessage(logoutMsg, (reply) => {
      _this._publish({ cmd: 'status', body: 'connected' });
    });
  }

  sendMessage(msg, replyCallback) {
    let _this = this;

    if (!msg.cmd)
      throw 'No mandatory field "cmd"';

    if (!msg.to)
      throw 'No mandatory field "to"';

    //automatic management of reply handlers
    if (replyCallback) {
      _this._id++;
      msg.id = _this._id;

      let replyId = msg.to + msg.id;
      _this._replyCallbacks[replyId] = replyCallback;

      setTimeout(() => {
        let replyFun = _this._replyCallbacks[replyId];
        delete _this._replyCallbacks[replyId];

        if (replyFun) {
          let errorMsg = { id: msg.id, cmd: 'error', from: msg.to, body: 'Reply timeout!' };
          replyFun(errorMsg);
        }
      }, _this._replyTimeOut);
    }

    _this._open(() => {
      _this._sock.send(JSON.stringify(msg));
    });
  }

  onMessage(callback) {
    let _this = this;
    _this._onMessage = callback;
  }

  _publish(msg) {
    let _this = this;

    if (_this._onMessage) {
      _this._onMessage(msg);
    }
  }

  _waitReady(callback) {
    let _this = this;

    if (_this._sock.readyState === 1) {
      callback();
    } else {
      setTimeout(() => {
        _this._waitReady(callback);
      });
    }
  }

  _open(callback) {
    let _this = this;

    if (!this._continuousOpen) {
      return;
    }

    if (!_this._sock) {
      if (_this._serverURL.substring(0, 2) === 'ws') {
        _this._sock = new WebSocket(_this._serverURL);
      } else {
        _this._sock = new SockJS(_this._serverURL);
      }

      _this._sock.onopen = function() {
        _this._publish({ cmd: 'status', body: 'connected' });
      };

      _this._sock.onmessage = function(event) {
        let msg = JSON.parse(event.data);

        if (msg.cmd === 'ok' || msg.cmd === 'error') {
          let replyId = msg.from + msg.id;
          let replyFun = _this._replyCallbacks[replyId];
          delete _this._replyCallbacks[replyId];

          if (replyFun) replyFun(msg);
        } else {
          _this._publish(msg);
        }
      };

      _this._sock.onclose = function(event) {
        let reason;

        //See https://tools.ietf.org/html/rfc6455#section-7.4
        if (event.code == 1000) {
          reason = 'Normal closure, meaning that the purpose for which the connection was established has been fulfilled.';
        } else if (event.code == 1001) {
          reason = 'An endpoint is \'going away\', such as a server going down or a browser having navigated away from a page.';
        } else if (event.code == 1002) {
          reason = 'An endpoint is terminating the connection due to a protocol error';
        } else if (event.code == 1003) {
          reason = 'An endpoint is terminating the connection because it has received a type of data it cannot accept (e.g., an endpoint that understands only text data MAY send this if it receives a binary message).';
        } else if (event.code == 1004) {
          reason = 'Reserved. The specific meaning might be defined in the future.';
        } else if (event.code == 1005) {
          reason = 'No status code was actually present.';
        } else if (event.code == 1006) {
          reason = 'The connection was closed abnormally, e.g., without sending or receiving a Close control frame';
        } else if (event.code == 1007) {
          reason = 'An endpoint is terminating the connection because it has received data within a message that was not consistent with the type of the message (e.g., non-UTF-8 [http://tools.ietf.org/html/rfc3629] data within a text message).';
        } else if (event.code == 1008) {
          reason = 'An endpoint is terminating the connection because it has received a message that "violates its policy". This reason is given either if there is no other sutible reason, or if there is a need to hide specific details about the policy.';
        } else if (event.code == 1009) {
          reason = 'An endpoint is terminating the connection because it has received a message that is too big for it to process.';
        } else if (event.code == 1010) {
          reason = 'An endpoint (client) is terminating the connection because it has expected the server to negotiate one or more extension, but the server didn\'t return them in the reply message of the WebSocket handshake. <br /> Specifically, the extensions that are needed are: ' + event.reason;
        } else if (event.code == 1011) {
          reason = 'A server is terminating the connection because it encountered an unexpected condition that prevented it from fulfilling the request.';
        } else if (event.code == 1015) {
          reason = 'The connection was closed due to a failure to perform a TLS handshake (e.g., the server certificate can\'t be verified).';
        } else {
          reason = 'Unknown reason';
        }

        delete _this._sock;
        _this._publish({ cmd: 'status', body: 'disconnected' });
      };
    } else {
      _this._waitReady(callback);
    }
  }
}
