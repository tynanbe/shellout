import gleam/should
import shellout.{StderrToStdout, cmd}

pub fn echo_test() {
  should.be_ok(cmd("echo", [], []))
}

pub fn enoent_test() {
  should.be_error(cmd("", [], []))
}

pub fn eacces_test() {
  should.be_error(cmd("/dev/null", [], []))
}

pub fn status_ok_test() {
  assert Ok(tuple(_, status)) = cmd("echo", [], [])
  should.equal(status, 0)
}

pub fn status_error_test() {
  assert Ok(tuple(_, status)) = cmd("ls", ["-a-"], [])
  should.not_equal(status, 0)
}

pub fn stdout_test() {
  assert Ok(tuple([output], _)) = cmd("printf", ["%s", "hi"], [])
  should.equal(output, "hi")
}

pub fn stderr_test() {
  assert Ok(tuple([output], _)) = cmd("ls", ["-a-", ""], [StderrToStdout(True)])
  should.not_equal(output, "")
}
