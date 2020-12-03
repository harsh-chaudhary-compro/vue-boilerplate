# vue-boilerplate
This is the frontend application buit using Vuejs framework

## Getting Started
### Prerequisites
Local development machine would need to have the following installed
- Nodejs - 12.x or later - Can be downloaded from [here](https://nodejs.org/en/download/) or use NVM if you need to have multiple node versions on your system
- Vue Cli - Standard tooling for Vue js Development. Follow the steps listed below to install Vue cli

```
npm install -g @vue/cli

# After installation, you will have access to the vue binary in your command line.

vue --version
```

### Cloning the repository
```
# Clone the Repo
git clone https://github.com/harsh-chaudhary-compro/vue-boilerplate.git

# Change directory
cd vue-boilerplate

# Run npm install
npm install
```

### To run project locally
```
# To run dev server (compiles and support hot-reloads)
npm run serve
```

### To generate build files
```
# To generate production build (compiles and minification)
npm run build
```

## Vue Configurations 
Vue js offers a number of configuration options while creating a new project using Vue Cli. This project is using the following Configuration Options
- **Babel** - JavaScript transcompiler that is mainly used to convert ECMAScript 2015+ code into a backwards compatible version of JavaScript that can be run by older JavaScript engines. 
- **Router** - Official Vue js router to provide client side routing for a Single Page application
    - Configured to use 'History' Mode
- **Vuex** - Vuex is a state management library for Vue.js applications. It serves as a centralized store for all the components in an application
- **CSS Pre-processor** - CSS preprocessor lets you generate CSS from the preprocessor's own unique syntax - providing features such as variables, mixins which doesn't exist in CSS. 
    - Sass/SCSS (with node-sass) is being used in this project
- **Linter** - A static code analysis tool for identifying problematic patterns found in JavaScript code to maintain code quality and to have consistent coding style.
    - ESLint + Airbnb configuration
    - Lint on save
- **Unit Testing** - Unit tests are automated tests written to ensure that a section of an application meets its behaviour as intended. 
    - 'Mocha' is selected as unit testing solution

Configuration files for Babel and ESLint are placed in the dedicated config files at the rrot of the project


## Project Structure


 ```
├─public                 # Folder for holding public files such as index html, favicon etc
│  │─index.html          # Main html file having websiste title etc 
│
├─src                    # Folder holding the Vue source files
│  │─assets              # Folder holding static assets for components like images, svgs etc
│  │─components          # Folder holding reusable Vue components which can be used across different pages
│  │─configurations      # Folder containing applications and environmental based configurations
│  │─router              # Folder containing routing configuration
│  │─store               # Application-level data for Vue components
│  │─views               # Folder containing Views/ Pages to be shown on a route
│  │─App.Vue             # Root level Vue component
│  │─main.js             # Main Js file initializing the Vue 
│
├─package.json           # Standard NPM package.json for dependencies and other metadata
├─vue.config.js          # Vue configuration to customaize webpack for dev server or build.
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/) for all possible configuration options, 'vue.config.js' file can be updated to add/update the configurations
