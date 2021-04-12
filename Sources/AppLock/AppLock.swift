import SwiftUI

/// A SwiftUI view that provides a user interface for writing `CodePin`.
/// To use,  set `completion` to
/// a closure that will be called when the number of pin digits is reached.  This will send the string that was detected or a `UnlockingError`.
public struct AppLockView: View {
    public enum UnlockError: Error {
        case badPin
    }
    /// Indicates whether of not the `ErrorView` should be shown
    public let enableErrorDisplay: Bool
    /// The code to be matched against
    public let rightPin: String
    /// Show A pop Up Display an error message
    public var completion: (Result<Bool, UnlockError>) -> Void

    @State private var pin: String = "3"
    @State private var showErrorView: Bool = false
    
    private let buttons: [String] = [ "1","2","3","4","5","6","7","8","9"," ","0","X"]
    
    public init(enableErrorDisplay: Bool = true, rightPin: String, completion:  @escaping (Result<Bool, UnlockError>) -> Void) {
        self.enableErrorDisplay = enableErrorDisplay
        if rightPin.count > 6 {
            fatalError("Can not create Pin Code with more than 6 digits")
        }
        self.rightPin = rightPin
        self.completion = completion
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            VStack {
                VStack(spacing: 20) {
                    Image(uiImage: fingerPrint)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 50, height: 50)

                    Text("App Locked")
                        .font(Font.title2.bold())
                    Text("Enter PIN")
                        .font(Font.callout.weight(.medium))
                    HStack(spacing: 20) {
                        ForEach(0..<rightPin.count) { i in
                            Image(systemName: "circle.fill")
                                .resizable()
                                .frame(width: 8, height: 8)
                                .foregroundColor(
                                    i < pin.count ? .primary : .secondary
                                )
                        }
                    }
                    .padding(.vertical, 10)

                    Button("Forgot?", action: {})
                        .font(.caption)
                        .hidden()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 100)
                LazyVGrid(columns: [
                    GridItem(.fixed(90)),
                    GridItem(.fixed(90)),
                    GridItem(.fixed(90)),
                ], spacing: 10) {
                    ForEach(buttons, id: \.self) { button in
                        Button {
                            if button == "X" {
                                if !pin.isEmpty {
                                    pin.removeLast()
                                }
                            } else {
                                pin.append(button)
                            }
                            impact(style: .rigid)
                        } label: {
                            Group {
                                if button == "X" {
                                    Image(systemName: "delete.left")
                                        .resizable()
                                        .frame(width: 22, height: 17)
                                        .opacity(pin.isEmpty ? 0 : 1)
                                } else {
                                    Text(button)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                    
                                }
                            }
                            .padding(10)
                        }
                        .frame(width: 60, height: 60)
                        .foregroundColor(
                            button == "X" ?
                                Color.red :
                                Color(.label)
                        )

                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            }
            .opacity(rightPin == pin ? 0 : 1)
            .onChange(of: pin, perform: onChange)
            
            if enableErrorDisplay {
                ErrorView(isShown: $showErrorView)
                    .offset(y: showErrorView ? 15 : -120)
                    .opacity(showErrorView ? 1 : 0)
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        
    }
    
    private func onChange(_ value: String) {
        if pin.count == rightPin.count {
            if pin == rightPin {
                completion(.success(true))
                showErrorView = false
            } else {
                completion(.failure(.badPin))
                if enableErrorDisplay {
                    
                    impact(style: .rigid)
                    withAnimation(.interactiveSpring()) {
                        showErrorView = true
                        DispatchQueue.main.asyncAfter(deadline: .now()+5.5) {
                            showErrorView = false
                        }
                    }
                }
            }
            pin = ""
        }
    }
    
    public var fingerPrint: UIImage {
        let image = UIImage(named: "fingerprint", in: .module, compatibleWith: nil)
        return image ?? UIImage(systemName: "lock.shield.fill")!
    }
    
    private func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
}

extension AppLockView {
    private struct ErrorView: View {
        @Binding public var isShown: Bool
        @State var loadingProgress: CGFloat = 1.0
        @State private var offset = CGSize.zero
        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Error")
                            .font(Font.title2.weight(.semibold))
                        Spacer()
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                            .onTapGesture {
                                isShown = false
                            }
                    }
                    Text("Wrong pin")
                        .font(Font.caption.weight(.light))
                }
                .padding(10)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Color.gray
                        Color.red
                            .frame(width: geo.size.width * loadingProgress)
                    }
                }
                .frame(height: 3)
                
            }
            .background(Color(.systemBackground))
            .cornerRadius(3)
            .shadow(color: .primary, radius: 0.5)
            .offset(y: offset.height)
            .padding()
            .animation(.interactiveSpring())
            .gesture(
                DragGesture()
                    .onChanged { offset = $0.translation }
                    .onEnded { _ in
                        offset = .zero
                    }
            )
            .onChange(of: isShown) { isPresented in
                if isPresented {
                    let _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                        if loadingProgress > 0.0 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                                loadingProgress -= 0.009
                            }
                        } else {
                            timer.invalidate()
                            withAnimation(.interactiveSpring()) {
                                loadingProgress = 1.0
                                isShown = false
                            }
                        }
                    }
                }
            }
        }
    }
}


struct AppLockView_Previews: PreviewProvider {
    static var previews: some View {
        AppLockView(rightPin: "1975") { result in
            // do nothing
        }
        
    }
}
