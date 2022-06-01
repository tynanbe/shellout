import { Error, Ok, toList } from "./gleam.mjs";
import { LetBeStderr, LetBeStdout, OverlappedStdio } from "./shellout.mjs";
import * as child_process from "child_process";
import * as fs from "fs";
import * as path from "path";

const Nil = undefined;
const Signals = {
  "SIGHUP": 1,
  "SIGINT": 2,
  "SIGQUIT": 3,
  "SIGILL": 4,
  "SIGTRAP": 5,
  "SIGABRT": 6,
  "SIGIOT": 6,
  "SIGBUS": 7,
  "SIGFPE": 8,
  "SIGKILL": 9,
  "SIGUSR1": 10,
  "SIGSEGV": 11,
  "SIGUSR2": 12,
  "SIGPIPE": 13,
  "SIGALRM": 14,
  "SIGTERM": 15,
  "SIGSTKFLT": 16,
  "SIGCHLD": 17,
  "SIGCONT": 18,
  "SIGSTOP": 19,
  "SIGTSTP": 20,
  "SIGTTIN": 21,
  "SIGTTOU": 22,
  "SIGURG": 23,
  "SIGXCPU": 24,
  "SIGXFSZ": 25,
  "SIGVTALRM": 26,
  "SIGPROF": 27,
  "SIGWINCH": 28,
  "SIGIO": 29,
  "SIGPOLL": 29,
  "SIGPWR": 30,
  "SIGSYS": 31,
  "SIGRTMIN": 34,
};

export function escape(code, string) {
  return `\x1b[${code}m${string}\x1b[0m\x1b[K`;
}

export function start_arguments() {
  return toList(process.argv.slice(1));
}

export function os_command(command, args, dir, opts) {
  let executable = os_which(command);
  executable =
    executable.isOk() ? executable : os_which(path.join(dir, command));
  if (!executable.isOk()) {
    return new Error([1, executable[0]]);
  }

  let getBool = (map, key) => {
    let result = map.get(key);
    return result.isOk() ? result[0] : false;
  };
  let stdin = "inherit";
  let stdout = "pipe";
  let stderr = "pipe";
  let spawnOpts = { cwd: dir, windowsHide: true };
  if (getBool(opts, new OverlappedStdio())) {
    stdin = stdout = "overlapped";
  }
  if (getBool(opts, new LetBeStderr())) {
    stderr = "inherit";
  }
  if (getBool(opts, new LetBeStdout())) {
    // Pass Ctrl+C to spawned process.
    process.on("SIGINT", () => Nil);
    stdout = "inherit";
  }
  spawnOpts.stdio = [stdin, stdout, stderr];
  let result = child_process.spawnSync(command, args.toArray(), spawnOpts);
  let output = result.stdout ? result.stdout.toString() : "";
  output += result.stderr ? result.stderr.toString() : "";
  let status = result.status;
  if (status === null) {
    let signal = Signals[result.signal];
    status = signal !== Nil ? signal : 0;
    // `yash`-like status
    // https://unix.stackexchange.com/a/99134
    status += 384;
  }
  return status === 0 ? new Ok(output) : new Error([status, output]);
}

export function os_which(command) {
  let pathexts = (process.env.PATHEXT || "").split(";");
  let paths = (process.env.PATH || "")
    .replace(/"+/g, "")
    .split(path.delimiter)
    .filter(Boolean)
    .map((item) => path.join(item, command))
    .concat([command])
    .flatMap((item) => pathexts.map((ext) => item + ext));
  let result = paths.map(
    (item) =>
      fs.statSync(item, { throwIfNoEntry: false })?.isFile() ? item : Nil,
  ).find((item) => item !== Nil);
  return result !== Nil ? new Ok(result) : new Error(
    `command \`${command}\` not found\n`,
  );
}
