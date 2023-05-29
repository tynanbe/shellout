export type Task = {
  name?: string;
  cmd: Array<string>;
};

export type Workbook = {
  readonly [index: string]: (...args: Array<string>) => void;
};

export const Workbook: Workbook = {
  check: (...args) => {
    args = args.length ? args : ["gleam", "typescript"];
    const item = (task: Task) => {
      if (typeof task.name !== "undefined" && args.includes(task.name)) {
        tasks.push(task);
      }
    };
    const tasks: Array<Task> = [];
    item({
      name: "gleam",
      cmd: ["gleam", "check"],
    });
    item({
      name: "typescript",
      cmd: ["deno", "check", "bin/task.ts"],
    });
    run(tasks);
  },

  format: (...args) => {
    const is_check = args.includes("--check");
    args = args.filter((x) => !["--check"].includes(x));
    args = args.length ? args : ["gleam", "erlang", "javascript"];
    const item = (task: Task) => {
      if (typeof task.name !== "undefined" && args.includes(task.name)) {
        if (is_check) {
          task.cmd.push("--check");
        }
        tasks.push(task);
      }
    };
    const tasks: Array<Task> = [];
    item({
      name: "gleam",
      cmd: [
        "gleam",
        "format",
        "src",
        "test",
      ],
    });
    item({
      name: "erlang",
      cmd: [
        "erlfmt",
        "src/shellout_ffi.erl",
        ...(is_check ? [] : ["--write"]),
      ],
    });
    item({
      name: "javascript",
      cmd: [
        "deno",
        "fmt",
        "deno.json",
        "tsconfig.json",
        "CHANGELOG.md",
        "README.md",
        "bin",
        "src",
        "test",
      ],
    });
    run(tasks);
  },

  help: () => {
    run([{ cmd: ["deno", "task"] }]);
  },

  test: (...args) => {
    args = args.length ? args : ["erlang", "deno", "node"];
    const item = (target: string, runtime?: string) => {
      if (args.includes(target) || runtime && args.includes(runtime)) {
        tasks.push({
          name: runtime ?? target,
          cmd: [
            "gleam",
            "test",
            `--target=${target}`,
            ...(runtime ? [`--runtime=${runtime}`] : []),
          ],
        });
      }
    };
    const tasks: Array<Task> = [];
    item("erlang");
    item("javascript", "deno");
    item("javascript", "node");
    run(tasks);
  },
};

const reset = "\x1b[0m\x1b[K";

const task = Workbook[Deno.args[0] ?? "help"] ?? Workbook["help"];
task?.(...Deno.args.slice(1));

export async function run(tasks: Array<Task>): Promise<void> {
  const total = tasks.length;
  if (!total) {
    error("no tasks to run");
    Deno.exit(1);
  }
  console.log();
  let acc = 0;
  for (const task of tasks) {
    if (typeof task.name !== "undefined") {
      console.log(`\x1b[35m  Targeting${reset} ${task.name}...`);
    }
    acc = (await Deno.run(task).status()).code ? acc + 1 : acc;
    console.log();
  }
  if (acc) {
    error(`${acc} of ${total} task runs failed`);
  }
  Deno.exit(acc);
}

function error(message: string): void {
  console.error(`\x1b[1;31merror${reset}\x1b[1m: ${message}${reset}`);
}
