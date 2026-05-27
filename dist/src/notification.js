class Notification {
    constructor() {
        this.handlers = new Map();
    }
    getQueue(name) {
        const queue = this.handlers.get(name);
        if (!queue) {
            this.handlers.set(name, []);
            return [];
        }
        else {
            return queue;
        }
    }
    listen(name, handler) {
        const queue = this.getQueue(name);
        this.handlers.set(name, queue.concat(handler));
    }
    once(name, handler) {
        this.handlers.set(name, [handler]);
    }
    off(name, handler) {
        const queue = this.getQueue(name);
        this.handlers.set(name, queue.filter(item => item !== handler));
    }
    clear(name) {
        this.handlers.set(name, []);
    }
    dispatch(name, ...args) {
        const queue = this.getQueue(name);
        queue.forEach(fn => fn(...args));
    }
}
export default Notification;
