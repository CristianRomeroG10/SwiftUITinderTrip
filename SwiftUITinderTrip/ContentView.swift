//
//  ContentView.swift
//  SwiftUITinderTrip
//
//  Created by Simon Ng on 17/7/2023.
//

import SwiftUI

struct ContentView: View {
    
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self{
            case .inactive, .pressing:
                return .zero
            case .dragging(let traslation):
                return traslation
            }
        }
        
        var isDragging: Bool {
            switch self{
            case .dragging:
                return true
            case .inactive, .pressing:
                return false
            }
        }
        
        var isPressing: Bool {
            switch self{
            case .pressing, .dragging:
                return true
            case .inactive:
                return false
            }
        }
    }
    
    @GestureState private var dragState = DragState.inactive
    private let dragThereshold: CGFloat = 80.0
    
    private func isTopCard(cardView: CardView)->Bool{
        guard let index = cardViews.firstIndex(where: { $0.id == cardView.id }) else {
            return false
        }
        return index == 0
    }
    
    @State var cardViews: [CardView] = {
        var views = [CardView]()
        for index in 0..<2 {
            views.append(CardView(image: trips[index].image, title: trips[index].destination
                                 )
            )
        }
        return views
    }()
    
    @State private var lastIndex = 1
    @State private var removalTransition = AnyTransition.trailingBottom
    
    private func moveCard(){
        cardViews.removeFirst()
        self.lastIndex += 1
        let trip = trips[lastIndex % trips.count]
        
        let newcardView = CardView(image: trip.image, title: trip.destination)
        cardViews.append(newcardView)
    }
    var body: some View {
        VStack {
            TopBarMenu()
            ZStack {
                ForEach(cardViews){ cardView in
                    cardView
                        .zIndex(self.isTopCard(cardView: cardView) ? 1 : 0)
                        .overlay{
                            ZStack {
                                Image(systemName: "x.circle")
                                    .foregroundColor(.red)
                                    .font(.system(size:100))
                                    .opacity(self.dragState.translation.width < -self.dragThereshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                                Image(systemName: "heart.circle")
                                    .foregroundColor(.green)
                                    .font(.system(size:100))
                                    .opacity(self.dragState.translation.width > self.dragThereshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                                    
                            }
                        }
                        .offset(x: self.isTopCard(cardView: cardView) ? self.dragState.translation.width : 0, y:self.isTopCard(cardView: cardView) ? self.dragState.translation.height : 0)
                        .scaleEffect(self.dragState.isDragging && self.isTopCard(cardView: cardView) ? 0.95 : 1.0)
                        .rotationEffect(Angle(degrees:self.isTopCard(cardView: cardView) ? Double(self.dragState.translation.width / 10):0))
                        .transition(self.removalTransition)
                        .animation(.interpolatingSpring(stiffness: 180, damping: 100), value: self.dragState.translation)
                        .gesture(LongPressGesture(minimumDuration: 0.01)
                            .sequenced(before: DragGesture())
                            .updating(self.$dragState, body: { (value, state,transaction) in
                                switch value {
                                case .first(true):
                                    state = .pressing
                                case .second(true, let drag):
                                    state = .dragging(translation: drag?.translation ?? .zero)
                                default:
                                    break
                                }
                            })
                                .onChanged({ (value) in
                                    guard case .second(true, let drag?) = value else {
                                        return
                                    }
                                    if drag.translation.width < -self.dragThereshold {
                                        self.removalTransition = .leadingBottom
                                    }
                                    if drag.translation.width > self.dragThereshold {
                                        self.removalTransition = .trailingBottom
                                    }
                                })
                                .onEnded({ (value) in
                                    guard case .second(true, let drag?) = value else {
                                        return
                                    }
                                    if drag.translation.width < -self.dragThereshold || drag.translation.width > self.dragThereshold {
                                        self.moveCard()
                                    }
                                })
                        )
                }
            }
            Spacer(minLength: 20)
            BottomBarMenu()
                .opacity(dragState.isDragging ? 0.0 : 1.0)
                .animation(.default, value: dragState.isDragging)
        }
    }
}

#Preview {
    ContentView()
}
#Preview("TopBarMenu"){
    TopBarMenu()
}
#Preview("BottomBarMenu"){
    BottomBarMenu()
}


struct TopBarMenu: View {
    var body: some View {
        HStack {
            Image(systemName: "line.horizontal.3")
                .font(.system(size: 30))
            Spacer()
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 35))
            Spacer()
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 30))
        }
        .padding()
    }
}

struct BottomBarMenu: View {
    var body: some View {
        HStack {
            Image(systemName: "xmark")
                .font(.system(size: 30))
                .foregroundColor(.black)
            Button {
                //Book the trip
            } label: {
                Text("BOOK IT NOW")
                    .font(.system(.subheadline, design: .rounded))
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 35)
                    .padding(.vertical, 15)
                    .background(.black)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            Image(systemName: "heart")
                .font(.system(size: 30))
                .foregroundStyle(.black)
        }
    }
}

extension AnyTransition {
    static var trailingBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: AnyTransition.move(
                edge: .trailing).combined(
                    with: .move(edge: .bottom)))
    }
    static var leadingBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: AnyTransition.move(
                edge: .leading).combined(
                    with: .move(edge: .bottom)))
    }
}
