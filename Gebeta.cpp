#include <iostream>
#include <iomanip>
#include <limits>
#include <cstdlib> 
#include <ctime>   
#include <string>

using namespace std;

// ------------ANSI COLOR CODES -----------------
const string RESET   = "\033[0m";
const string RED     = "\033[31m";
const string GREEN   = "\033[32m";
const string YELLOW  = "\033[33m";
const string BLUE    = "\033[34m";
const string CYAN    = "\033[36m";
const string BOLD    = "\033[1m";

/* ------------------ RULES ------------------ */
void showRules()
{
    cout << CYAN << "\n=========== GEBETA RULES ===========\n" << RESET;
        cout << GREEN << "1. 12 holes total, 2 rows of 6.\n"
            << GREEN << "2. Player 1 has bottom row, Player 2 top row.\n"
            << GREEN << "3. Each hole starts with 4 seeds.\n"
            << GREEN << "4. Starter is chosen completely at random.\n"
            << GREEN << "5. Pick from your own side holes only.\n"
            << YELLOW << "6. Harvest all seeds from the chosen hole.\n"
            << YELLOW << "7. Sow counter-clockwise dropping 1 seed per hole.\n"
            << YELLOW << "8. " << BOLD << "THE ASTERISK (*)" << RESET << YELLOW << ": Highlights the exact last hole where sowing ended.\n"
            << YELLOW << "9. Capture occurs when a hole hits exactly 4 seeds.\n"
            << YELLOW << "10. Captured seeds add to the hole owner's score.\n"
            << RED << "11. Multi-lap: if last seed lands on >1 seeds, pick up and continue.\n"
            << RED << "12. Turn ends when last seed lands in an empty hole.\n"
            << RED << "13. Skipping or passing turns is forbidden.\n"
            << RED << "14. Game ends when a player has no valid moves.\n"
            << RED << "15. Remaining board seeds go to their row owners.\n"
            << RED << "16. The player with the highest final score wins.\n"
         << CYAN << "====================================\n\n" << RESET;
}

/* ------------------ GAME CODE ------------------ */

const int HOLES = 12;
const int START_SEEDS = 4;

struct Node
{
    int seeds;
    bool isP1;
    Node* next;
};

Node* createBoard()
{
    Node* head = new Node;
    Node* curr = head;

    for (int i = 0; i < HOLES; i++)
    {
        curr->seeds = START_SEEDS;
        curr->isP1 = (i >= 6);

        if (i < HOLES - 1)
        {
            curr->next = new Node;
            curr = curr->next;
        }
    }

    curr->next = head;
    return head;
}

void showBoard(Node* head, int s1, int s2, int turn, string p1Name, string p2Name, Node* lastLanded)
{
    cout << CYAN << "\n=================================================\n";
    cout << "              GEBETA - ETHIOPIAN GAME\n";
    cout << "=================================================\n" << RESET << "\n";

    Node* temp = head;
    int p2[6], p1[6];
    bool p2Last[6] = {false}, p1Last[6] = {false};

    for (int i = 0; i < 6; i++)
    {
        p2[i] = temp->seeds;
        if (temp == lastLanded) p2Last[i] = true;
        temp = temp->next;
    }

    for (int i = 0; i < 6; i++)
    {
        p1[i] = temp->seeds;
        if (temp == lastLanded) p1Last[i] = true;
        temp = temp->next;
    }

    cout << p2Name << " >> " << (turn == 1 ? YELLOW + "*** YOUR TURN ***" + RESET : "") << "\n\n";

    for (int i = 5; i >= 0; i--)
    {
        cout << BLUE << "[" << RESET << p2[i] << BLUE << "]" << RESET << (p2Last[i] ? RED + "* " + RESET : "  ");
    }
    cout << "\n";

    for (int i = 6; i >= 1; i--)
    {
        cout << " " << i << "   ";
    }
    cout << "\n\n";

    for (int i = 0; i < 6; i++)
    {
        cout << BLUE << "[" << RESET << p1[i] << BLUE << "]" << RESET << (p1Last[i] ? RED + "* " + RESET : "  ");
    }
    cout << "\n";

    for (int i = 1; i <= 6; i++)
    {
        cout << " " << i << "   ";
    }
    cout << "\n\n";

    cout << p1Name << " >> " << (turn == 0 ? YELLOW + "*** YOUR TURN ***" + RESET : "") << "\n";

    cout << "\n----------------------------------------\n";
    cout << "Scores -> " << p1Name << ": " << s1
         << " | " << p2Name << ": " << s2 << "\n";
    cout << "----------------------------------------\n";
}

bool hasMove(Node* head, bool isP1)
{
    Node* temp = head;

    for (int i = 0; i < HOLES; i++)
    {
        if (temp->isP1 == isP1 && temp->seeds > 0)
            return true;
        temp = temp->next;
    }
    return false;
}
void checkCapture(Node* node, int& s1, int& s2, bool movingPlayer)
{
    if (node->seeds == 4)
    {
        if (movingPlayer)
        {
            s1 += 4;
            node->seeds = 0;
            cout << GREEN << "Player 1 captured 4 seeds!\n" << RESET;
        }
        else
        {
            s2 += 4;
            node->seeds = 0;
            cout << GREEN << "Computer/Player 2 captured 4 seeds!\n" << RESET;
        }
    }
}

/* --------------------- FULL SAFE INPUT FOR GAMEPLAY ----------------------- */
Node* getValidChoice(Node* head, bool isP1, string playerName)
{
    int choice;

    if (playerName == "Computer")
    {
        while (true)
        {
            choice = (rand() % 6) + 1; 
            Node* temp = head;
            for (int i = 1; i < choice; i++) temp = temp->next;

            if (temp->seeds > 0)
            {
                cout << "Computer chooses pit: " << choice << "\n";
                return temp;
            }
        }
    }

    while (true)
    {
        cout << playerName << ", enter pit (1-6): ";
        cin >> choice;

        if (cin.fail())
        {
            cin.clear();
            cin.ignore(numeric_limits<streamsize>::max(), '\n');
            cout << RED << "Invalid input! Please enter a NUMBER between 1 and 6.\n" << RESET;
            continue;
        }

        if (choice < 1 || choice > 6)
        {
            cout << RED << "Invalid range! Choose between 1 and 6.\n" << RESET;
            continue;
        }

        Node* temp = head;

        if (isP1)
        {
            for (int i = 0; i < 6; i++) temp = temp->next;
            for (int i = 1; i < choice; i++) temp = temp->next;
        }
        else
        {
            for (int i = 1; i < choice; i++) temp = temp->next;
        }

        if (temp->seeds == 0)
        {
            cout << RED << "Empty pit! Choose another.\n" << RESET;
            continue;
        }

        return temp;
    }
}

void playTurn(Node* head, bool isP1, int& s1, int& s2, string playerName, Node*& lastLanded)
{
    Node* start = getValidChoice(head, isP1, playerName);

    int seeds = start->seeds;
    start->seeds = 0;

    Node* curr = start;

    while (seeds > 0)
    {
        curr = curr->next;
        curr->seeds++;
        seeds--;
        checkCapture(curr, s1, s2, isP1);
    }

    while (curr->seeds > 1)
    {
        seeds = curr->seeds;
        curr->seeds = 0;

        while (seeds > 0)
        {
            curr = curr->next;
            curr->seeds++;
            seeds--;
            checkCapture(curr, s1, s2, isP1);
        }
    }
    
    lastLanded = curr; 
}

void collectAll(Node* head, int& s1, int& s2)
{
    Node* temp = head;

    for (int i = 0; i < HOLES; i++)
    {
        if (temp->isP1) s1 += temp->seeds;
        else s2 += temp->seeds;

        temp->seeds = 0;
        temp = temp->next;
    }
}
/* --------------------------- MAIN -------------------------- */
int main()
{
    srand(time(0)); 
    int choice;
    string lastWinner = ""; // Global reference storage tracking the winner through main cycles

    while (true)
    {
        cout << "\n===========MENU ===========\n";
        cout << GREEN << "1. Start Game\n" << RESET;
        cout << YELLOW << "2. View Rules\n" << RESET;
        cout << RED << "3. Exit\n" << RESET;
        cout << "Enter choice: ";
        cin >> choice;

        if (cin.fail())
        {
            cin.clear();
            cin.ignore(numeric_limits<streamsize>::max(), '\n');
            cout << RED << "Invalid input! Please enter numbers only.\n" << RESET;
            continue;
        }

        if (choice == 1)
        {
            int gameMode;
            string p1Name = "", p2Name = "";

            while (true)
            {
                cout << "\n--- " << GREEN << "CHOOSE " << YELLOW << "GAME " << RED << "MODE" << RESET << " ---\n";
                cout << "1. Play with Computer\n";
                cout << "2. Play with your friend\n";
                cout << "Enter choice: ";
                cin >> gameMode;

                if (cin.fail() || (gameMode != 1 && gameMode != 2))
                {
                    cin.clear();
                    cin.ignore(numeric_limits<streamsize>::max(), '\n');
                    cout << RED << "Invalid Option! Choose 1 or 2.\n" << RESET;
                    continue;
                }
                break;
            }

            if (gameMode == 1)
            {
                while (true)
                {
                    cout << "Enter Player name: ";
                    cin >> p1Name;
                    if (p1Name == "Computer") 
                    {
                        cout << RED << "Name cannot be 'Computer'. Choose another name.\n" << RESET;
                        continue;
                    }
                    break;
                }
                p2Name = "Computer";
            }
            else // Play with your friend option branch
            {
                int friendOption;
                while (true)
                {
                    cout << "\n--- FRIEND PLAY MODE ---\n";
                    cout << "1. Play with winner\n";
                    cout << "2. New player\n";
                    cout << "Enter choice: ";
                    cin >> friendOption;

                    if (cin.fail() || (friendOption != 1 && friendOption != 2))
                    {
                        cin.clear();
                        cin.ignore(numeric_limits<streamsize>::max(), '\n');
                        cout << RED << "Invalid Option! Choose 1 or 2.\n" << RESET;
                        continue;
                    }
                    break;
                }

                if (friendOption == 1)
                {
                    if (lastWinner == "" || lastWinner == "Computer")
                    {
                        cout << RED << "\n[Notice] No prior friend game winner saved yet! Setup new names:\n" << RESET;
                        cout << "Enter Player 1 name: ";
                        cin >> p1Name;
                        while (true)
                        {
                            cout << "Enter Player 2 name: ";
                            cin >> p2Name;
                            if (p1Name == p2Name)
                            {
                                cout << RED << "Error: Names must be unique!\n" << RESET;
                                continue;
                            }
                            break;
                        }
                    }
                    else
                    {
                        // Bring the previous winner to Player 1 spot automatically
                        p1Name = lastWinner;
                        cout << "\nReturning Champion: " << GREEN << p1Name << RESET << "\n";
                        while (true)
                        {
                            cout << "Enter challenger name (Player 2): ";
                            cin >> p2Name;
                            if (p1Name == p2Name)
                            {
                                cout << RED << "Error: You cannot play against yourself! Choose a unique name.\n" << RESET;
                                continue;
                            }
                            if (p2Name == "Computer")
                            {
                                cout << RED << "Error: Name cannot be 'Computer'.\n" << RESET;
                                continue;
                            }
                            break;
                        }
                    }
                }
                else // New player setup sequence
                {
                    cout << "Enter Player 1 name: ";
                    cin >> p1Name;
                    while (true)
                    {
                        cout << "Enter Player 2 name: ";
                        cin >> p2Name;
                        if (p1Name == p2Name)
                        {
                            cout << RED << "Error: Player 2 cannot have the same name as Player 1! Please use a unique name.\n" << RESET;
                            continue;
                        }
                        break;
                    }
                }
            }

            int turn = rand() % 2; 
            cout << "\n[System] Selecting starter randomly...\n";
            cout << "[System] " << BOLD << (turn == 0 ? p1Name : p2Name) << RESET << " will start first!\n";

            Node* board = createBoard();
            Node* lastLanded = NULL; 
            int score1 = 0, score2 = 0;

            while (true)
            {
                showBoard(board, score1, score2, turn, p1Name, p2Name, lastLanded);

                if (!hasMove(board, true) || !hasMove(board, false))
                    break;

                if (turn == 0)
                    playTurn(board, true, score1, score2, p1Name, lastLanded);
                else
                    playTurn(board, false, score1, score2, p2Name, lastLanded);

                turn = 1 - turn;
            }

            collectAll(board, score1, score2);

            cout << YELLOW << "\nGAME OVER!\n" << RESET;
            showBoard(board, score1, score2, -1, p1Name, p2Name, lastLanded);

            if (score1 > score2)
            {
                cout << GREEN << p1Name << " Wins!\n" << RESET;
                lastWinner = p1Name; // Assign structural winner memory tracking
            }
            else if (score2 > score1)
            {
                cout << GREEN << p2Name << " Wins!\n" << RESET;
                lastWinner = p2Name; 
            }
            else
            {
                cout << YELLOW << "Draw!\n" << RESET;
                lastWinner = ""; // Reset since game ended balanced
            }
        }
        else if (choice == 2)
        {
            showRules();
        }
        else if (choice == 3)
        {
            cout << "Exiting game...\n";
            break;
        }
        else
        {
            cout << RED << "Invalid choice!\n" << RESET;
        }
    }

    return 0;
}
