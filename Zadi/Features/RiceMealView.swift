//
//  RiceMealView.swift
//  Projectزادي
//
//  Created by Nouf Fayez on 13/05/1448 AH.
// 

import SwiftUI

struct RiceMealView: View {

   // "girl" or "boy" – what the child chose at the start
   var character: String = "boy"
    

   // MARK: - Part 2: Logic

   // The foods the child selected (empty = rice only)
   @State private var selected: Set<String> = []

   // Part 3: what the character is saying now (nil = just smiling)
   @State private var message: CoachMessage?

   // The 4 buttons, left → right like the design
   let foods = [
       Food(id: "chicken", arabicName: "دجاج",  icon: "riceChickenIngredient",
            voice: "الدجاج مليء بالبروتين، يجعل عضلاتك قوية!"),
       Food(id: "yogurt",  arabicName: "زبادي", icon: "yogurt",
            voice: "الزبادي مفيد لعظامك وأسنانك!"),
       Food(id: "salad",   arabicName: "سلطة",  icon: "salad",
            voice: "السلطة مليئة بالفيتامينات، تجعلك نشيطا وصحيا!"),
       Food(id: "fries",   arabicName: "بطاطس", icon: "potato", isHealthy: false,
            voice: "البطاطس المقلية لذيذة، لكن فيها زيت كثير. ما رأيك أن تجرب السلطة بدلا منها؟")
   ]

   // Which image to show on the plate for each selection.
   let mealImages: [Set<String>: String] = [
       []: "Rice_only",
       ["chicken"]: "Rice_chicken",
       ["yogurt"]:  "Rice_yogurt",
       ["fries"]:   "Rice_fries",
       ["salad"]:   "Rice_salad",

       ["chicken", "yogurt"]: "Rice_chicken_yogurt",
       ["chicken", "fries"]:  "Rice_chicken_fries",
       ["chicken", "salad"]:  "Rice_chicken_salad",
       ["yogurt", "fries"]:   "Rice_yogurt_fries",
       ["yogurt", "salad"]:   "Rice_yogurt_salad",
       ["fries", "salad"]:    "Rice_fries_salad",

       ["chicken", "yogurt", "fries"]: "Rice_chicken_yogurt_fries",
       ["chicken", "yogurt", "salad"]: "Rice_chicken_yogurt_salad",
       ["chicken", "fries", "salad"]:  "Rice_chicken_fries_salad",
       ["yogurt", "fries", "salad"]:   "Rice_yogurt_fries_salad",

       ["chicken", "yogurt", "fries", "salad"]: "RiceWithAllFour"
   ]

    
   // Tap once = add to the plate, tap again = remove it
   func toggle(_ food: Food) {
       let added = !selected.contains(food.id)

       withAnimation(.spring) {
           if added {
               selected.insert(food.id)
           } else {
               selected.remove(food.id)
           }
       }

       // Part 3: the character reacts and speaks
       let onPlate = foods.filter { selected.contains($0.id) }
       message = Coach.react(to: food, added: added, selected: onPlate)
       Speaker.shared.say(message?.voice ?? "")
   }

   // MARK: - Part 1: Environment

   var body: some View {
       ZStack {
           // The meal on the plate (covers the rice in the background)
           if let meal = mealImages[selected] {
               Image(meal)
                   .resizable()
                   .scaledToFit()
                   .frame(width: 400, height: 305)
                   .id(meal)
                   .transition(.scale(scale: 0.85).combined(with: .opacity))
                   .position(x: 695, y: 308)
           }

           // The question
          
           // The 4 food buttons
           HStack(spacing: 58) {
               ForEach(foods, id: \.self) { food in
                   foodButton(food)
               }
           }
           .environment(\.layoutDirection, .leftToRight)   // keep دجاج on the left
           .position(x: 761, y: 853)

           // The character + speech bubble (Part 3)
           CharacterView(character: character, message: message)
               .position(x: 152, y: 897)
       }
       .frame(maxWidth: .infinity, maxHeight: .infinity)
       .background {
           Image("KitchenBackGround")
               .resizable()
               .scaledToFill()
       }
       .ignoresSafeArea()
       .statusBarHidden()
       .onDisappear { Speaker.shared.stop() }   // stop talking when leaving the screen
   }

   // One gray food button (glows when selected)
   func foodButton(_ food: Food) -> some View {
       let isSelected = selected.contains(food.id)

       return Button {
           toggle(food)
       } label: {
           VStack(spacing: 2) {
               Image(food.icon)
                   .resizable()
                   .scaledToFit()
                   .frame(width: 178, height: 137)

               Text(food.arabicName)
                   .font(.system(size: 35, weight: .bold, design: .rounded))
                   .foregroundStyle(.white)
                   .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
           }
           .frame(width: 198, height: 221)
           .background(Color(red: 0.74, green: 0.74, blue: 0.77).opacity(0.92))
           .clipShape(RoundedRectangle(cornerRadius: 44))
           .overlay(
               RoundedRectangle(cornerRadius: 44)
                   .stroke(.white, lineWidth: isSelected ? 5 : 0)
           )
           .shadow(color: .white.opacity(isSelected ? 0.95 : 0), radius: 20)
           .scaleEffect(isSelected ? 1.06 : 1)
       }
       .buttonStyle(.plain)
   }
}

#Preview(traits: .landscapeLeft) {
   RiceMealView()
}
