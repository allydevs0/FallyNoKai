#!/usr/bin/env node

const readline = require("readline");
const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

// CONFIGURAÇÃO
const modelo = "<modelo>"; // Substitua pelo seu modelo Ollama
const historyFile = path.join(__dirname, "history.txt");

// Função para salvar histórico
function saveHistory(prompt, response) {
    fs.appendFileSync(historyFile, `PROMPT: ${prompt}\nRESPOSTA: ${response}\n\n`);
}

// Função para buscar arquivos recursivamente
function findFiles(dir, exts = [".js", ".py", ".ts", ".dart"]) {
    let results = [];
    fs.readdirSync(dir, { withFileTypes: true }).forEach((file) => {
        const fullPath = path.join(dir, file.name);
        if (file.isDirectory()) {
            results = results.concat(findFiles(fullPath, exts));
        } else if (exts.includes(path.extname(file.name))) {
            results.push(fullPath);
        }
    });
    return results;
}

// Função para chamar Ollama
function callOllama(prompt) {
    try {
        const response = execSync(`ollama chat ${modelo} "${prompt}"`, { encoding: "utf-8" });
        return response;
    } catch (err) {
        return `Erro ao chamar Ollama: ${err.message}`;
    }
}

// CLI interativo
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: "VibeCoding> "
});

console.log("🎵 Vibe Coding CLI - powered by Ollama 🎵");
rl.prompt();

rl.on("line", (line) => {
    const input = line.trim();

    if (input.toLowerCase() === "sair") {
        console.log("Até a próxima! 👋");
        rl.close();
        return;
    }

    // COMANDOS ESPECIAIS
    if (input.startsWith("listar ")) {
        // listar <extensao>
        const ext = input.split(" ")[1] || ".js";
        const files = findFiles(process.cwd(), [ext, ".dart"]); // adiciona .dart
        console.log("Arquivos encontrados:\n" + files.join("\n"));
        rl.prompt();
        return;
    }

    if (input.startsWith("ler ")) {
        // ler <arquivo>
        const filePath = input.split(" ")[1];
        if (!filePath || !fs.existsSync(filePath)) {
            console.log("Arquivo não encontrado!");
        } else {
            const content = fs.readFileSync(filePath, "utf-8");
            console.log(`\nConteúdo de ${filePath}:\n\n${content}`);
        }
        rl.prompt();
        return;
    }

    if (input.startsWith("corrigir ")) {
        // corrigir <arquivo>
        const filePath = input.split(" ")[1];
        if (!filePath || !fs.existsSync(filePath)) {
            console.log("Arquivo não encontrado!");
        } else {
            const code = fs.readFileSync(filePath, "utf-8");
            const prompt = `Revise este código Dart e corrija erros:\n\n${code}`;
            const response = callOllama(prompt);
            console.log("\n💻 Correção:\n" + response);
            saveHistory(prompt, response);
        }
        rl.prompt();
        return;
    }

    // DEFAULT: pergunta normal para Ollama
    const response = callOllama(input);
    console.log("\n💻 Resposta:\n" + response);
    saveHistory(input, response);
    rl.prompt();
}).on("close", () => {
    process.exit(0);
});
