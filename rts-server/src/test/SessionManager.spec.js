import Client from '../js/Client';
import chai from 'chai';

let expect = chai.expect;

describe('SessionManager', function() {
	it('login and logout', function(done) {
		let seq = 0;

		let client = new Client('ws://localhost:9090/ws');
		client.onMessage((msg) => {
			console.log(msg);
			seq++;

			if (seq === 1) {
				expect(msg).to.eql({cmd: 'status', body: 'connected'});
			}

			if (seq === 2) {
				expect(msg).to.eql({cmd: 'status', body: 'session'});

				client.logout();
			}

			if (seq === 3) {
				expect(msg).to.eql({cmd: 'status', body: 'connected'});

				done();
			}
		});

		client.login('shumy', 'password', 'game');
	});
});
