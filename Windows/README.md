# Typewriter Sounds Program ( keyboardtypo )

## Description
This program plays any embded .wav file when you press buttons on your keyboard.

It aims to recreate the nostalgic experience of using a typewriter while typing on your computer.

## Installation / compile
1. Clone the repository to your local machine using the following command:
   ```
   git clone https://github.com/your-username/typewriter-sounds.git
   ```
2. Ensure that you have msys64 installed and configured on your machine.

3.
   ```
   run ucrt64 and
   make clean && make
   ```

## Usage

1. Run the program.
2. Try typing something.

## Configuration
You can customize the program by modifying the `ss_ui_type.rc` file:
- `101 RCDATA `: Set custom .wav
- `102 ICON `: Set custom ICO.

`make clean && make`: to apply.

## Compatibility
This program has been tested on Windows 10, but it should work on other Windows versions as well.

## Contributing
If you would like to contribute to this project, you can fork the repository, make your changes, and submit a pull request. Any suggestions or improvements are welcome!

## License
This program is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
