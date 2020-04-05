import UIKit

class BookAPIPageViewController: UIPageViewController
{
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getGoogleAPIViewController(withIdentifier: "Page1"),
            self.getGoodreadsAPIViewController(withIdentifier: "Page2"),
            self.getOpenLibraryAPIViewController(withIdentifier: "Page3"),
//            self.getViewController(withIdentifier: "Page4")
        ]
    }()
    
    public var googleBook: GoogleAPIBook?
    
    public var goodreadsBook: GoodreadsAPIBook?
    
    public var openLibraryBook: OpenLibraryAPIBook?
    
    var currIndex: Int = 0
    
    fileprivate func getGoogleAPIViewController(withIdentifier identifier: String) -> UIViewController
    {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) as! GoogleBookAPIViewController
        vc.book = googleBook
        return vc
    }
    
    fileprivate func getGoodreadsAPIViewController(withIdentifier identifier: String) -> UIViewController
    {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) as! GoodreadsAPIViewController
        vc.book = goodreadsBook
        return vc
    }
    
    fileprivate func getOpenLibraryAPIViewController(withIdentifier identifier: String) -> UIViewController
    {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier) as! OpenLibraryAPIViewController
        vc.book = openLibraryBook
        return vc
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        
        if let firstVC = pages.first
        {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension BookAPIPageViewController: UIPageViewControllerDataSource
{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return pages.last }
        
        guard pages.count > previousIndex else { return nil        }
        
        currIndex = previousIndex
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return pages.first }
        
        guard pages.count > nextIndex else { return nil         }
        
        currIndex = nextIndex
        
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currIndex
    }
}

extension BookAPIPageViewController: UIPageViewControllerDelegate { }
