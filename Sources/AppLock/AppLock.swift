import SwiftUI

/// A SwiftUI view that provides a user interface for writing `CodePin`.
/// To use,  set `completion` to
/// a closure that will be called when the number of pin digits is reached.  This will send the string that was detected or a `UnlockingError`.
public struct AppLockView: View {
    public enum UnlockError: String, Error {
        case badPin
        case invalidPin = "Invalid PIN, the PIN may be betweed 4 to 6 digit"
    }
    public struct PinCode: Equatable {
        init(_ value: String) { self.value = value }
        init(_ value: Int) {  self.value = String(value)  }
        
        let value: String
        
        var isValid: Bool { (4...6).contains(value.count) }
        
    }
    /// String displayed at the top, can be tht app/service name
    public let title: LocalizedStringKey
    /// Indicates whether of not the `ErrorView` should be shown
    private let enableErrorDisplay: Bool
    /// The code to be matched against should between (4 to 6 digits)
    public let correctPin: PinCode
    
    /// The primary color to be used for the View
    public let primaryColor: Color
    
    /// Show A pop Up Display an error message
    public var completion: (Result<Bool, UnlockError>) -> Void

    @State private var enteredPin: String = ""
    @State private var showErrorView: Bool = false
    @Namespace private var animation
    
    private let buttons: [String] = [ "1","2","3","4","5","6","7","8","9"," ","0","X"]
    
    public init(title: LocalizedStringKey = "AppLock",
                color: Color = .primary,
                enableErrorDisplay: Bool = false,
                pincode: PinCode,
                completion:  @escaping (Result<Bool, UnlockError>) -> Void) {
        
        guard pincode.isValid else { fatalError(UnlockError.invalidPin.localizedDescription) }
        
        self.enableErrorDisplay = enableErrorDisplay
        self.title = title
        self.correctPin = pincode
        self.primaryColor = color
        self.completion = completion
    }
    
    @available(*, deprecated, message: "Use `init(title:enableErrorDisplay:pincode:completion:)` instead")
    public init(title: LocalizedStringKey = "AppLock",
                enableErrorDisplay: Bool = false,
                rightPin: String,
                completion:  @escaping (Result<Bool, UnlockError>) -> Void) {
        self.init(title: title,
                  color: .primary,
                  enableErrorDisplay: enableErrorDisplay,
                  pincode: PinCode(rightPin),
                  completion: completion)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            VStack {
                VStack(spacing: 20) {
                    Image(uiImage: fingerPrint)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 50, height: 50)

                    Text(title)
                        .font(Font.title2.bold())
                    Text("Enter PIN")
                        .font(Font.callout.weight(.semibold))
                    HStack(spacing: 20) {
                        ForEach(0..<correctPin.value.count) { i in
                            ZStack {
                                if !(i < enteredPin.count) {
                                    Rectangle()
                                        .frame(width: 12, height: 2)
                                        .frame(height: 30, alignment: .bottom)
                                        .matchedGeometryEffect(id: i, in: animation)
                                        .foregroundColor(.secondary)
                                } else {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: 12, height: 12)
                                        .frame(height: 20, alignment: .top)
                                        .matchedGeometryEffect(id: i, in: animation)
                                        .foregroundColor(primaryColor)
                                }
                            }
                        }
                    }
                    .frame(height: 30)
                    .padding(.vertical)

                    Button("Forgot?", action: {})
                        .font(.caption)
                        .hidden()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 60)
                .foregroundColor(primaryColor)

                
                LazyVGrid(columns: [
                    GridItem(.fixed(90)),
                    GridItem(.fixed(90)),
                    GridItem(.fixed(90)),
                ], spacing: 10) {
                    ForEach(buttons, id: \.self) { button in
                        Button {
                            withAnimation(.easeIn(duration: 0.1)) {
                                if button == "X" {
                                    if !enteredPin.isEmpty {
                                        enteredPin.removeLast()
                                    }
                                } else {
                                    enteredPin.append(button)
                                }
                            }
                            
                            impact(style: .rigid)
                        } label: {
                            Group {
                                if button == "X" {
                                    Image(systemName: "delete.left")
                                        .resizable()
                                        .frame(width: 22, height: 17)
                                        .opacity(enteredPin.isEmpty ? 0 : 1)
                                } else {
                                    Text(button)
                                        .font(.system(size: 25, weight: .semibold, design: .rounded))
                                    
                                }
                            }
                            .padding(10)
                        }
                        .frame(width: 70, height: 70)
                        .foregroundColor(
                            button == "X" ?
                                Color.red :
                                Color(.label)
                        )

                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.bottom, 60)

            }
            .opacity(correctPin.value == enteredPin ? 0 : 1)
            .onChange(of: enteredPin, perform: onChange)
            
            if enableErrorDisplay {
                ErrorView(isShown: $showErrorView)
                    .offset(y: showErrorView ? 15 : -120)
                    .opacity(showErrorView ? 1 : 0)
            }
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        
    }
    
    private func onChange(_ value: String) {
        if enteredPin.count == correctPin.value.count {
            if enteredPin == correctPin.value {
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
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                withAnimation(.easeIn(duration: 0.15)) {
                    enteredPin = ""
                }
            }
           
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
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Error")
                            .font(Font.title2.weight(.semibold))
                        Text("Wrong pin")
                            .font(Font.caption.weight(.light))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                        .onTapGesture {
                            isShown = false
                        }
                }
                .padding(10)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Color.gray
                        Color.red
                            .frame(width: max(geo.size.width * loadingProgress, 0))
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
        AppLockView(color: Color.blue, pincode: AppLockView.PinCode("22992")) { result in
            //             do nothing
        }
        //        .preferredColorScheme(.dark)
        
    }
}
