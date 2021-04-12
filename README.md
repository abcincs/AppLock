# AppLock

A description of this package.

<p>
    <img src="https://img.shields.io/badge/iOS-14.0+-blue.svg" />
    <img src="https://img.shields.io/badge/Swift-5.1-red.svg" />
    <a href="https://twitter.com/cedricbahirwe">
        <img src="https://img.shields.io/badge/Contact-@cedricbahirwe-lightgrey.svg?style=flat" alt="Twitter: @cedricbahirwe" />
    </a>
</p>

AppLock is a simple SwiftUI framework that makes it easy to create a PinCode user interface. It provides a struct, `AppLockView`, that can be shown inside a view or a sheet for better user experience.


## Usage

You should create an instance of `AppLockView` with three parameters: the pin to check against, a boolean flag to indicate whether or not you want AppLockView to provide an Error UI, and a closure that will be called when a result is ready. This closure must accept a `Result<Bool, UnlockError>`, where the bool is the indicator of a matching that was found on success and `UnlockError` will be either `badPin`.

**Important:** AppLockView *requires* a project with a version greater or equal to `14.0`


## Examples

Here's some example code to create an AppLock view that prints when the pin matched code.

```swift
AppLockView(rightPin: "1975") { result  in
    switch result {
    case .success(_):
        print("Match pin code")
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

Your completion closure is probably where you want to dismiss the `AppLockView`.

Here's an example on how to present the AppLockview as a sheet and how we can pass to the next view in a NavigationView when code matches:

```swift
struct AppLockExampleView: View {
    @State var isPresentingLocker = false
    @State var matchedCode: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                if matchedCode {
                    NavigationLink("Next page", destination: NextView(), isActive: .constant(true)).hidden()
                }
                Button("Unlock App") {
                    self.isPresentingLocker = true
                }
                .sheet(isPresented: $isPresentingLocker) {
                    self.appLockSheet
                }
                Text("Unlock the app to begin")
            }

        }
    }

    var appLockSheet : some View {
        AppLockView(
            rightPin: "2021",
            completion: { result in
                if case .success(_) = result {
                    self.matchedCode = true
                    self.isPresentingLocker = false
                }
            }
        )
    }
}
```


## Credits

AppLock was made by [Cédric Bahirwe](https://twitter.com/cedricbahirwe). It’s available under the MIT license, which permits commercial use, modification, distribution, and private use.


## License

MIT License.

Copyright (c) 2021 Cédric Bahirwe

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
