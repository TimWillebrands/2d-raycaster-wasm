const canvas = document.getElementById('game')
const ctx = canvas.getContext('2d')
const wallsCanvas = document.getElementById('walls')
const wallsCtx = wallsCanvas.getContext('2d')

const env = {
    IsBlocked: function (srcX, srcY, tarX, tarY) {
        const pixel = wallsCtx.getImageData(tarX-1, tarY-1, 1, 1)
        // if(pixel.data[3] > 0) console.log
        return pixel.data[3] > 0
    },
    Log: function (x, y, z) {
        console.log('[wasm]', x, y, z)
        return false
    }
}

const importObject = new Proxy(env, {
    get (target, prop, receiver) {
        if (env[prop] !== undefined) {
            return env[prop].bind(env)
        }
        return (...args) => {
            throw new Error(`NOT IMPLEMENTED: ${prop} ${args}`)
        }
    }
})

const wasm = await WebAssembly.instantiateStreaming(
    fetch('lighting.wasm'), { env: importObject })

wasm.instance.exports._initialize()

console.time('[perf] init')
wasm.instance.exports.init()
console.timeEnd('[perf] init')

const size = 60 * 2 + 1
function update(x, y, r){
    console.time('[perf] update')
    const canvasPtr = wasm.instance.exports.put(34, r, x, y)
    console.timeEnd('[perf] update')

    console.time('[perf] canvas')
    ctx.clearRect(0, 0, 180, 180)
    const mem = wasm.instance.exports.memory.buffer
    const cells = new Uint8ClampedArray(mem, canvasPtr, size * size * 4)
    const imageData = new ImageData(cells, size, size)
    ctx.putImageData(imageData, x - size/2, y - size/2)

    ctx.globalCompositeOperation = 'destination-over'
    ctx.fillStyle = 'black'
    ctx.fillRect(0, 0, 180, 180)
    console.timeEnd('[perf] canvas')
}

const form = new FormData(document.getElementById('controls'))
update(form.get('x'), form.get('y'), form.get('radius'))

document.getElementById('controls')
    .addEventListener('input', function(ev) {
        const form = new FormData(ev.target.parentElement)
        update(form.get('x'), form.get('y'), form.get('radius'))
    })

function draw(ev){
    ev.preventDefault()
    ev.stopPropagation()

    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;   // Horizontal scale factor
    const scaleY = canvas.height / rect.height; // Vertical scale factor
    const x = (event.clientX - rect.left) * scaleX;
    const y = (event.clientY - rect.top) * scaleY;

    if(ev.buttons === 1 || ev.buttons === 2){
        if(x < 0 || x >= 180 || y < 0 || y >= 180) return;

        const pixel = ev.buttons === 1 ? 255 : 0 
        const canvasPtr = wasm.instance.exports.toggleBlock(x, y, pixel)
        const mem = wasm.instance.exports.memory.buffer
        const cells = new Uint8ClampedArray(mem, canvasPtr, 180*180*4)
        const imageData = new ImageData(cells, 180, 180)
        wallsCtx.putImageData(imageData, 0, 0)

        const form = new FormData(document.getElementById('controls'))
        update(form.get('x'), form.get('y'), form.get('radius'))
    }
    if(ev.buttons === 4){
        if(x < 0 || x >= 180 || y < 0 || y >= 180) return;
        update(x, y, form.get('radius'))
    }
}
wallsCanvas.addEventListener('pointermove', draw)
wallsCanvas.addEventListener('pointerdown', draw)
