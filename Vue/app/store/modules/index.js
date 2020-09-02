/**
 * Automatically imports all the modules and exports as a single module object
 */
const requireModule = require.context('.', true, /\.module\.js$/);
const modules = {};

requireModule.keys().forEach(filename => {
    // create the module name from fileName
    // remove the module.js extension and capitalize
    const moduleName = filename
        .replace(/(\.\/|\.module\.js)/g, '')
        .replace(/^\w/, c => c.toUpperCase())

    modules[moduleName] = requireModule(filename).default || requireModule(filename);
});

export default modules;