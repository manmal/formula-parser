export class Parser extends TinyEmitter {
    constructor();
    parse(expression: string): [error: string | null, result: any | null];
    setVariable(name: string, value: any);
    getVariable(name: string): any;
    setFunction(name: string, func: Function);
    getFunction(name: string): Function;
}